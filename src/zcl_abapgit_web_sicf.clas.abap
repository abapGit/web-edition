CLASS zcl_abapgit_web_sicf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ABAPGIT_WEB_SICF IMPLEMENTATION.


  METHOD if_http_extension~handle_request.


    DATA(lv_path) = cl_http_utility=>if_http_utility~unescape_url( server->request->get_header_field( '~path' ) ).

    DATA(li_assets) = zcl_abapgit_ui_factory=>get_asset_manager( ).

*    DATA lo_html_preprocessor TYPE REF TO zcl_abapgit_gui_html_processor.
*    CREATE OBJECT lo_html_preprocessor EXPORTING ii_asset_man = li_assets.
*    lo_html_preprocessor->preserve_css( 'css/ag-icons.css' ).
*    lo_html_preprocessor->preserve_css( 'css/common.css' ).
*    lo_html_preprocessor->zif_abapgit_gui_html_processor~process( ).

    CASE lv_path.
      WHEN '/sap/zabapgit/css/common.css'.
        ls_asset = li_assets->get_asset( 'css/common.css' ).
        server->response->set_content_type( 'text/css' ).
        server->response->set_data( ls_asset-content ).
      WHEN '/sap/zabapgit/css/ag-icons.css'.
        ls_asset = li_assets->get_asset( 'css/ag-icons.css' ).
        server->response->set_content_type( 'text/css' ).
        server->response->set_data( ls_asset-content ).
      WHEN '/sap/zabapgit/font/ag-icons.woff'.
        ls_asset = li_assets->get_asset( 'font/ag-icons.woff' ).
        server->response->set_content_type( 'font/woff' ).
        server->response->set_data( ls_asset-content ).
      WHEN '/sap/zabapgit/js/common.js'.
        ls_asset = li_assets->get_asset( 'js/common.js' ).
        server->response->set_content_type( 'text/javascript' ).
        server->response->set_data( ls_asset-content ).
*      WHEN '/sap/zabapgit/css/bundle.css'.
*        ls_asset = li_assets->get_asset( 'css/bundle.css' ).
*        server->response->set_data( ls_asset-content ).
      WHEN '/sap/zabapgit/' OR '/sap/zabapgit/css/bundle.css'.
        zcl_abapgit_ui_injector=>set_html_viewer( NEW zcl_abapgit_html_viewer_web( server ) ).
        zcl_abapgit_ui_factory=>get_gui( )->go_home( ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
