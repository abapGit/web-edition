CLASS zcl_abapgit_web_sicf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_extension .
  PROTECTED SECTION.

    DATA mo_viewer TYPE REF TO zcl_abapgit_html_viewer_web .
    CONSTANTS gc_base TYPE string VALUE '/sap/zabapgit/' ##NO_TEXT.
    DATA mo_gui TYPE REF TO zcl_abapgit_gui .

    METHODS initialize
      IMPORTING
        !ii_server TYPE REF TO if_http_server .
    METHODS sapevent
      IMPORTING
        !ii_server TYPE REF TO if_http_server .
    METHODS redirect
      IMPORTING
        !ii_server TYPE REF TO if_http_server .
    METHODS search_asset
      IMPORTING
        !ii_server      TYPE REF TO if_http_server
      RETURNING
        VALUE(rv_found) TYPE abap_bool .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ABAPGIT_WEB_SICF IMPLEMENTATION.


  METHOD if_http_extension~handle_request.

    server->set_session_stateful( ).

    IF mo_viewer IS INITIAL.
      initialize( server ).
    ENDIF.

    DATA(lv_found) = search_asset( server ).
    IF lv_found = abap_true.
      RETURN.
    ENDIF.

    DATA(lv_path) = cl_http_utility=>if_http_utility~unescape_url( server->request->get_header_field( '~path' ) ).
    IF lv_path = '/sap/zabapgit'.
      redirect( server ).
    ELSEIF lv_path = gc_base.
      mo_gui->go_home( ).
    ELSEIF lv_path = |{ gc_base }css/bundle.css|.
      mo_viewer->zif_abapgit_html_viewer~show_url( |css/bundle.css| ).
    ELSEIF lv_path CP |{ gc_base }sapevent:+*|.
      sapevent( server ).
    ENDIF.

  ENDMETHOD.


  METHOD initialize.

    mo_viewer = NEW zcl_abapgit_html_viewer_web( ii_server ).

    zcl_abapgit_ui_injector=>set_html_viewer( mo_viewer ).

    mo_gui = zcl_abapgit_ui_factory=>get_gui( ).

  ENDMETHOD.


  METHOD redirect.

    DATA lv_html TYPE string.

    lv_html =
      |<!DOCTYPE html>\n| &&
      |<html>\n| &&
      |   <head>\n| &&
      |      <title>HTML Meta Tag</title>\n| &&
      |      <meta http-equiv = "refresh" content = "0; url = { gc_base }" />\n| &&
      |   </head>\n| &&
      |   <body>\n| &&
      |      <p>Redirecting</p>\n| &&
      |   </body>\n| &&
      |</html>|.

    ii_server->response->set_cdata( lv_html ).

  ENDMETHOD.


  METHOD sapevent.

* todo, parse and pass data
* todo, respect GET and POST

    DATA: lt_fields  TYPE tihttpnvp,
          lv_action  TYPE c LENGTH 100,
          lv_getdata TYPE c LENGTH 100,
          ls_field   LIKE LINE OF lt_fields.

    ii_server->request->get_header_fields( CHANGING fields = lt_fields ).

    READ TABLE lt_fields WITH KEY name = '~request_uri' INTO ls_field.
    REPLACE FIRST OCCURRENCE OF gc_base IN ls_field-value WITH ''.

    FIND REGEX '^sapevent:(\w+)' IN ls_field-value SUBMATCHES lv_action.

    FIND REGEX '\?([\w=&]+)' IN ls_field-value SUBMATCHES lv_getdata.

    mo_viewer->raise_event(
      iv_action  = lv_action
      iv_getdata = lv_getdata ).

  ENDMETHOD.


  METHOD search_asset.

    DATA ls_asset TYPE zif_abapgit_gui_asset_manager=>ty_web_asset.


    DATA(lv_path) = cl_http_utility=>if_http_utility~unescape_url( ii_server->request->get_header_field( '~path' ) ).

    DATA(li_assets) = zcl_abapgit_ui_factory=>get_asset_manager( ).

    IF lv_path CP |{ gc_base }+*|.
      DATA(lv_search) = lv_path.
      REPLACE FIRST OCCURRENCE OF gc_base IN lv_search WITH ''.
      TRY.
          ls_asset = li_assets->get_asset( lv_search ).
          ii_server->response->set_content_type( |{ ls_asset-type }/{ ls_asset-subtype }| ).
          ii_server->response->set_data( ls_asset-content ).
          rv_found = abap_true.
        CATCH zcx_abapgit_exception.
          rv_found = abap_false.
      ENDTRY.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
