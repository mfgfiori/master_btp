@AbapCatalog.sqlViewName: 'ZV_EMPL_2114'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface - Employees'
define root view Z_I_EMPLOYEE_2114
  as select from zemployee_2114  as Employees
{
    //Employees
  key e_number,
      e_name,
      e_department,
      status,
      job_title,
      start_date, 
      end_date,
      email,
      m_number,
      m_name,
      m_department,
      crea_date_time,
      crea_uname,
      lchg_date_time,
      lchg_uname

}
