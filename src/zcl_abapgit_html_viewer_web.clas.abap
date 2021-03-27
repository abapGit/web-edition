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


  METHOD zif_abapgit_html_viewer~back.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~close_document.

    RETURN.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~free.

    RETURN.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~get_url.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~load_data.

    IF iv_url = 'css/bundle.css'.
      CONCATENATE LINES OF ct_data_table INTO mv_css IN CHARACTER MODE RESPECTING BLANKS.
    ELSEIF iv_url = ''.
      CONCATENATE LINES OF ct_data_table INTO mv_html IN CHARACTER MODE RESPECTING BLANKS.
    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~set_registered_events.

    RETURN.

  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~set_visiblity.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_html_viewer~show_url.

    DATA(lv_path) = cl_http_utility=>if_http_utility~unescape_url( mi_server->request->get_header_field( '~path' ) ).

    DATA(lv_js) = |<script>                               \n| &&
      |function registerLinks() \{                        \n| &&
      |  const links = document.getElementsByTagName("a");\n| &&
      |  for (let i = 0; i < links.length; i++) \{        \n| &&
      |    if (links[i].href.startsWith("sapevent:")) \{  \n| &&
      |      links[i].href = "./" + links[i].href;        \n| &&
      |    \}          \n| &&
      |  \}            \n| &&
      |\}              \n| &&
      |registerLinks();\n| &&
      |function processForm(e) \{ \n| &&
      |  if (e.preventDefault) e.preventDefault(); \n| &&
      |  console.dir(e);\n| &&
      |  return false;  \n| &&
      |\}               \n| &&
      |function registerForms() \{                           \n| &&
      |  const forms = document.getElementsByTagName("form");\n| &&
      |  for (let i = 0; i < forms.length; i++) \{           \n| &&
      |    forms[i].addEventListener("submit", processForm); \n| &&
      |    console.dir(forms[i]);\n| &&
      |  \}            \n| &&
      |\}              \n| &&
      |registerForms();\n| &&
      |</script></body>\n|.

    IF lv_path = '/sap/zabapgit/css/bundle.css'.
      mi_server->response->set_content_type( 'text/css' ).
      mi_server->response->set_cdata( mv_css ).
    ELSEIF lv_path = '/sap/zabapgit/' OR lv_path CP |/sap/zabapgit/sapevent:+*|.
      REPLACE FIRST OCCURRENCE OF |</body>| IN mv_html WITH lv_js.
      mi_server->response->set_content_type( 'text/html' ).
      mi_server->response->set_cdata( mv_html ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
