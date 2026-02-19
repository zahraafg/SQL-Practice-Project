USE RealCompanyDB;

/* 🧩 RealCompanyDB – SQL Practice Project

Mövzu: Employee & Department Analizi

🎯 Tapşırıq

RealCompanyDB bazasından istifadə edərək elə bir sorğu yaz ki:

Hər departament üzrə işçilərin sayı (employee count)

Hər departamentdə aktiv layihədə çalışan işçilərin sayı

Hər işçinin maaşı ilə departament üzrə orta maaşı göstərmək

CASE ilə maaşı statuslandırmaq:

maaş > 1.5 * ortalama → 'HIGH'

maaş > ortalama → 'ABOVE_AVG'

əks halda → 'NORMAL'

Yalnız 3-dən çox işçisi olan departamentlər göstərilsin

Nəticəni department_name, sonra salary DESC sıralamaq */

select 
	e.department_id,
	d.department_name,
	e.full_name,
	e.salary,

	t.emp_count,
	f.active_emp_count,

	AVG(e.salary) over(partition by e.department_id) as avg_salary,

	case 
	when e.salary > 1.5 * AVG(e.salary) over(partition by e.department_id) then 'HIGH'
	when e.salary > AVG(e.salary) over(partition by e.department_id) then 'ABOVE_AVG'
	else 'NORMAL'
	end as salary_status

from Employees e
join Departments d
on d.department_id = e.department_id

left join (
	select department_id, COUNT(*) as emp_count
	from Employees 
	group by department_id
	) t 
on t.department_id = e.department_id

left join (
	select e.department_id, COUNT(distinct e.employee_id) as active_emp_count
	from Employees e
	left join EmployeeProjects ep
	on e.employee_id = ep.employee_id
	left join Projects p
	on p.project_id = ep.project_id
	where p.end_date is null
	group by e.department_id
	) f
on f.department_id = e.department_id
where t.emp_count >= 3
order by d.department_name, salary desc;

-- OR 

with DepartmentCounts as (
    select department_id, COUNT(*) as emp_count
	from Employees 
	group by department_id
	),
ActiveProjects as (
	select e.department_id, COUNT(distinct e.employee_id) as active_emp_count
	from Employees e
	join EmployeeProjects ep
	on e.employee_id = ep.employee_id
	join Projects p
	on p.project_id = ep.project_id
	where p.end_date is null
	group by e.department_id
	)
select
    e.department_id,
	d.department_name,
	e.full_name,
	e.salary,

	dc.emp_count,
	ap.active_emp_count,
	t.avg_salary,

	case 
	when e.salary > 1.5 * AVG(e.salary) over(partition by e.department_id) then 'HIGH'
	when e.salary > AVG(e.salary) over(partition by e.department_id) then 'ABOVE_AVG'
	else 'NORMAL'
	end as salary_status

from Employees e
join Departments d
on d.department_id = e.department_id
left join DepartmentCounts dc
on e.department_id = dc.department_id
left join ActiveProjects ap
on e.department_id = ap.department_id
join (
select department_id, AVG(salary) as avg_salary
from Employees
group by department_id
) t
on e.department_id = t.department_id
where dc.emp_count >= 3
order by d.department_name, e.salary desc;













