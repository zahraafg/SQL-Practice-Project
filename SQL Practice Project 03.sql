-- Analyze employee performance and bonuses:
-- Calculate total and average bonuses, project count, status, and salary ranking within departments

USE RealCompanyDB;

select 
	e.employee_id,
	e.full_name,
	e.salary,
	e.department_id,
	d.department_name,
	COALESCE(SUM(b.bonus_amount), 0) as total_bouns,
	COUNT(distinct ep.employee_id) as pro_count,
	COALESCE(AVG(b.bonus_amount), 0) as avg_bouns,

	case 
		when COALESCE(SUM(b.bonus_amount), 0) > 500 then 'TOP BONUS'
		when COALESCE(SUM(b.bonus_amount), 0) > 200 then 'MEDIUM BONUS'
	else 'LOW BONUS'
	end as status,
	rank() over (partition by e.department_id order by e.salary desc) as salary_rank
from Employees e
left join Departments d
on d.department_id = e.department_id
left join Bonuses b
on b.employee_id = e.employee_id
left join EmployeeProjects ep
on e.employee_id = ep.employee_id

group by 
    e.employee_id,
	e.full_name,
	e.salary,
	e.department_id,
	d.department_name
order by d.department_name, salary_rank;

-- OR 

with EmployeeBonus as (
select 
	e.employee_id,
	e.full_name,
	e.salary,
	e.department_id,
	COALESCE(SUM(b.bonus_amount), 0) as total_bouns,
	COALESCE(AVG(b.bonus_amount), 0) as avg_bouns

from Employees e
left join Bonuses b
on e.employee_id = b.employee_id
group by 
    e.employee_id,
	e.full_name,
	e.salary,
	e.department_id
),
EmployeeProjectsCount as (
	select e.employee_id,
	COUNT(distinct ep.project_id) as pro_count
	from Employees e
	left join EmployeeProjects ep
	on e.employee_id = ep.employee_id
	group by e.employee_id
)
select 
    e.employee_id,
	e.full_name,
	e.salary,
	e.department_id,
	eb.total_bouns,
    pc.pro_count,

    eb.avg_bouns,

	case 
	when eb.total_bouns > 500 then 'TOP BONUS'
	when eb.total_bouns > 200 then 'MEDIUM BONUS'
	else 'LOW BONUS'
	end as status,
	rank() over (partition by e.department_id order by e.salary desc) as salary_rank
from Employees e
left join Departments d
on d.department_id = e.department_id
left join EmployeeBonus eb
on eb.employee_id = e.employee_id
left join EmployeeProjectsCount pc
on e.employee_id = pc.employee_id
order by d.department_name, salary_rank;
