CLASS zcl_abapgit_html_viewer_web DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_html_viewer .

    METHODS constructor
      IMPORTING
        !ii_server TYPE REF TO if_http_server .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mi_server TYPE REF TO if_http_server .
ENDCLASS.



CLASS ZCL_ABAPGIT_HTML_VIEWER_WEB IMPLEMENTATION.


  METHOD constructor.

    mi_server = ii_server.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~close_document.

    RETURN.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~free.

    RETURN.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~load_data.

    DATA: lv_xstr TYPE xstring.
    FIELD-SYMBOLS: <lv_mime> TYPE w3_mime.

    DATA(lv_path) = cl_http_utility=>if_http_utility~unescape_url( mi_server->request->get_header_field( '~path' ) ).

    IF url = 'css/bundle.css' AND lv_path = '/sap/zabapgit/css/bundle.css'.
      mi_server->response->set_content_type( 'text/css' ).
      mi_server->response->set_cdata( concat_lines_of( data_table ) ).
    ENDIF.

    IF lv_path = '/sap/zabapgit/' AND subtype = 'html'.
      mi_server->response->set_content_type( 'text/html' ).
      mi_server->response->set_cdata( concat_lines_of( data_table ) ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~set_registered_events.

    RETURN.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~show_url.

    RETURN.

  ENDMETHOD.
ENDCLASS.
