CLASS zcl_book_load_data_2114 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BOOK_LOAD_DATA_2114 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lt_acccateg TYPE TABLE OF ztb_acccateg2114,
          lt_catego   TYPE TABLE OF ztb_catego_2114,
          lt_cliente  TYPE TABLE OF ztb_cliente_2114,
          lt_clnt_lib TYPE TABLE OF ztb_clnt_lib2114,
          lt_libros   TYPE TABLE OF ztb_libros_2114.

** Acceso por Categorías **
    lt_acccateg = VALUE #(
    ( bi_categ = 'A' tipo_acceso = '1' )
    ( bi_categ = 'B' tipo_acceso = '1' )
    ( bi_categ = 'C' tipo_acceso = '2' )
    ( bi_categ = 'D' tipo_acceso = '3' )
     ).
    DELETE FROM ztb_acccateg2114.
    INSERT ztb_acccateg2114 FROM TABLE @lt_acccateg.
    SELECT * FROM ztb_acccateg2114 INTO TABLE @lt_acccateg.
    out->write( sy-dbcnt ).
    out->write( 'ztb_acccateg2114 data inserted successfully!').

** Categorías **
    lt_catego = VALUE #(
    ( bi_categ = 'A' descripcion = 'Categoría A' )
    ( bi_categ = 'B' descripcion = 'Categoría B' )
    ( bi_categ = 'C' descripcion = 'Categoría C' )
    ( bi_categ = 'D' descripcion = 'Categoría D' )
     ).
    DELETE FROM ztb_catego_2114.
    INSERT ztb_catego_2114 FROM TABLE @lt_catego.
    SELECT * FROM ztb_catego_2114 INTO TABLE @lt_catego.
    out->write( sy-dbcnt ).
    out->write( 'ztb_catego_2114 data inserted successfully!').

** Cliente **
    lt_cliente = VALUE #(
    ( id_cliente  = 'CLNT_0001'      tipo_acceso = '1'
        nombre = 'Carlos'  apellidos = 'Sanchez Perez'
        email = 'carlos.sanchez@gmail.com'
        url = 'https://discovery-center.cloud.sap/serviceCatalog/sap-translation-hub?region=all&tab=feature' )
    ( id_cliente  = 'CLNT_0002'     tipo_acceso = '2'
        nombre = 'Susana'  apellidos = 'Gomez Garcia'
        email = 'sgomezgarcia@gmail.com'
        url = 'https://logaligroup.com/curso/sap-btp-abap-en-cloud/')
    ( id_cliente  = 'CLNT_0003'     tipo_acceso = '3'
        nombre = 'Carmen'   apellidos = 'Lopez Lopez'
        email = 'clopezlopez@gmail.com'
        url = 'https://logaligroup.com/sap-adobe-forms-order-template/')
     ).
    DELETE FROM ztb_cliente_2114.
    INSERT ztb_cliente_2114 FROM TABLE @lt_cliente.
    SELECT * FROM ztb_cliente_2114 INTO TABLE @lt_cliente.
    out->write( sy-dbcnt ).
    out->write( 'ztb_cliente_2114 data inserted successfully!').

** Cliente/Libros **
    lt_clnt_lib = VALUE #(
    ( id_cliente = 'CLNT_0001' id_libro = '0000000001' )
    ( id_cliente = 'CLNT_0001' id_libro = '0000000002' )
    ( id_cliente = 'CLNT_0003' id_libro = '0000000003' )
     ).
    DELETE FROM ztb_clnt_lib2114.
    INSERT ztb_clnt_lib2114 FROM TABLE @lt_clnt_lib.
    SELECT * FROM ztb_clnt_lib2114 INTO TABLE @lt_clnt_lib.
    out->write( sy-dbcnt ).
    out->write( 'ztb_clnt_lib2114 data inserted successfully!').

** Cliente/Libros **
    lt_libros = VALUE #(
    ( id_libro = '0000000001'
      bi_categ = 'A'
      titulo   = 'ABAP RESTful Application Programming Model'
      autor    = 'Michael Lensch'
      editorial = 'SAP_PRESS'
      idioma   = 'E'
      paginas  = 560
      precio   = '84.95'
      moneda   = 'EUR'
      formato  = 'PDF'
      url = 'https://www.sap-press.com/abap-restful-application-programming-model_5647/' )
    ( id_libro = '0000000002'
      bi_categ = 'A'
      titulo   = 'SAP Business Technology Platform'
      autor    = 'Chun Aun Gooi'
      editorial = 'SAP_PRESS'
      idioma   = 'E'
      paginas  = 570
      precio   = '74.99'
      moneda   = 'EUR'
      formato  = 'MOBI'
      url = 'https://www.sap-press.com/sap-business-technology-platform_5440/' )

    ( id_libro = '0000000003'
      bi_categ = 'D'
      titulo   = 'Por si las voces vuelven'
      autor    = 'Ángel Martín'
      editorial = 'Planeta'
      idioma   = 'S'
      paginas  = 256
      precio   = '17'
      moneda   = 'EUR'
      formato  = 'Libro'
      url = 'https://www.fnac.es/a8707553/Angel-Martin-Por-si-las-voces-vuelven' )
     ).

    DELETE FROM ztb_libros_2114.
    INSERT ztb_libros_2114 FROM TABLE @lt_libros.
    SELECT * FROM ztb_libros_2114 INTO TABLE @lt_libros.
    out->write( sy-dbcnt ).
    out->write( 'ztb_libros_2114 data inserted successfully!').

  ENDMETHOD.
ENDCLASS.
