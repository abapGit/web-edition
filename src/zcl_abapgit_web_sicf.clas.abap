CLASS zcl_abapgit_web_sicf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_extension .
  PROTECTED SECTION.

    CONSTANTS gc_base TYPE string VALUE '/sap/zabapgit/' ##NO_TEXT.

    METHODS redirect
      IMPORTING
        !ii_server TYPE REF TO if_http_server .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ABAPGIT_WEB_SICF IMPLEMENTATION.


  METHOD if_http_extension~handle_request.

    DATA ls_asset TYPE zif_abapgit_gui_asset_manager=>ty_web_asset.


    DATA(lv_path) = cl_http_utility=>if_http_utility~unescape_url( server->request->get_header_field( '~path' ) ).

    DATA(li_assets) = zcl_abapgit_ui_factory=>get_asset_manager( ).

    IF lv_path CP |{ gc_base }+*|.
      DATA(lv_search) = lv_path.
      REPLACE FIRST OCCURRENCE OF gc_base IN lv_search WITH ''.
      TRY.
          ls_asset = li_assets->get_asset( lv_search ).
          server->response->set_content_type( |{ ls_asset-type }/{ ls_asset-subtype }| ).
          server->response->set_data( ls_asset-content ).
          RETURN.
        CATCH zcx_abapgit_exception.
      ENDTRY.
    ENDIF.

    CASE lv_path.
      WHEN '/sap/zabapgit'.
        redirect( server ).
      WHEN '/sap/zabapgit/' OR '/sap/zabapgit/css/bundle.css'.
        zcl_abapgit_ui_injector=>set_html_viewer( NEW zcl_abapgit_html_viewer_web( server ) ).
        zcl_abapgit_ui_factory=>get_gui( )->go_home( ).
    ENDCASE.

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
ENDCLASS.
