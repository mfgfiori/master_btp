@EndUserText.label: 'Consumption-HC Master'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity z_c_hc_master_2114
  as projection on z_i_hc_master_2114
{
      @ObjectModel.text.element: ['EmployeeName']
  key ENumber      as EmployeeNumber,
      EName        as EmployeeName,
      EDepartment  as EmployeeDepartment,
      Status       as EmployeeStatus,
      JobTitle     as JobTitle,
      StartDate,
      EndDate,
      Email,
      @ObjectModel.text.element: ['ManagerName']
      MNumber      as ManagerNumber,
      MName        as ManagerName,
      MDepartment  as ManagerDepartment,
      @Semantics.user.createdBy: true
      CreaDateTime as CreatedOn,      
      CreaUname    as CreatedBy,
      @Semantics.user.lastChangedBy: true      
      LchgDateTime as ChangedOn,
      LchgUname    as ChangedBy

}
