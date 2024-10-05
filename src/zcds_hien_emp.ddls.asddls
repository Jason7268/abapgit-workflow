@AbapCatalog.sqlViewName: 'ZCDSHIENEMP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Test View'
@Metadata.ignorePropagatedAnnotations: true
define view ZCDS_HIEN_EMP
  as select from    zthien_emp     as _Employee
    left outer join zthien_hlthpln as _HealthPlan on _Employee.hlth_plan = _HealthPlan.hlth_plan
{
  key _Employee.emp_id      as EmpId,
      _Employee.lastname    as Lastname,
      _Employee.first_name  as FirstName,
      _Employee.hlth_plan   as HlthPlan,
      _HealthPlan.plan_name as PlanName
}
