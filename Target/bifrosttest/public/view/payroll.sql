create or replace view BIFROSTTEST.PUBLIC.PAYROLL(
	"Employee Name",
	"Department",
	"Salary"
) as
select  e.emp_name as "Employee Name",
        d.Dept_Name as "Department",
        d.dept_sal as "Salary"
From PUBLIC.Dept d, PUBLIC.Employee e where d.dept_id = e.dept_id;
