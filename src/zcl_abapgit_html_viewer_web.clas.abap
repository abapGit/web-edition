CLASS zcl_abapgit_html_viewer_web DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_html_viewer .

    METHODS raise_event
      IMPORTING
        iv_action TYPE clike
        iv_getdata TYPE clike.
    METHODS constructor
      IMPORTING
        !ii_server TYPE REF TO if_http_server .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mv_html TYPE string.
    DATA mv_css TYPE string.
    DATA mi_server TYPE REF TO if_http_server .
ENDCLASS.



CLASS ZCL_ABAPGIT_HTML_VIEWER_WEB IMPLEMENTATION.


  METHOD constructor.

    mi_server = ii_server.

  ENDMETHOD.


  METHOD raise_event.

* todo, all parameters as input

    RAISE EVENT zif_abapgit_html_viewer~sapevent
      EXPORTING
        action      = iv_action
        getdata     = iv_getdata
        postdata    = VALUE #( )
        query_table = VALUE #( ).

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~close_document.

    RETURN.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~free.

    RETURN.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~load_data.

    IF iv_url = 'css/bundle.css'.
      mv_css = concat_lines_of( ct_data_table ).
    ELSEIF iv_url = ''.
      mv_html = concat_lines_of( ct_data_table ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~set_registered_events.

    RETURN.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~show_url.

    DATA(lv_path) = cl_http_utility=>if_http_utility~unescape_url( mi_server->request->get_header_field( '~path' ) ).

    DATA(js) = |<script>                                  | &&
    |  function registerLinks() \{                        | &&
    |    const links = document.getElementsByTagName("a");| &&
    |    for (let i = 0; i < links.length; i++) \{        | &&
    |      if (links[i].href.startsWith("sapevent:")) \{  | &&
    |        links[i].href = "./" + links[i].href;        | &&
    |      \}        | &&
    |    \}          | &&
    |  \}            | &&
    |registerLinks();| &&
    |</script></body>|.

    IF lv_path = '/sap/zabapgit/css/bundle.css'.
      mi_server->response->set_content_type( 'text/css' ).
      mi_server->response->set_cdata( mv_css ).
    ELSEIF lv_path = '/sap/zabapgit/' OR lv_path CP |/sap/zabapgit/sapevent:+*|.
      REPLACE FIRST OCCURRENCE OF |</body>| IN mv_html WITH js.
      mi_server->response->set_content_type( 'text/html' ).
      mi_server->response->set_cdata( mv_html ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
