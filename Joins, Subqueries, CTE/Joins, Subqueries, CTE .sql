(01)
--Use SoftUni 
SELECT TOP 5 EmployeeID, JobTitle, e.AddressID, Addresses.AddressText FROM Employees as e
JOIN Addresses ON e.AddressID = Addresses.AddressID
ORDER BY e.AddressID

(02)
SELECT TOP 50 FirstName, LastName, t.Name, a.AddressText FROM Employees as e
JOIN  Addresses AS a ON e.AddressID = a.AddressID 
JOIN Towns as t ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName

(03)
SELECT EmployeeID, FirstName, LastName, d.Name FROM Employees as e
JOIN Departments as d ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY EmployeeID

(04)
SELECT TOP 5 e.EmployeeID, e.FirstName, e.Salary, d.Name AS DepartmentName FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID

(05)
SELECT TOP 3 e.EmployeeID, e.FirstName FROM Employees AS e
LEFT JOIN EmployeesProjects AS p ON p.EmployeeID = e.EmployeeID
WHERE p.EmployeeID IS NULL
ORDER BY p.EmployeeID

(06)
SELECT FirstName, LastName, HireDate, d.Name AS DeptName FROM Employees as e 
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE (d.Name = 'Finance' OR d.Name = 'Sales') AND e.HireDate > '1999-01-01'
ORDER BY e.HireDate

(07)
SELECT TOP 5 e.EmployeeID, FirstName, p.Name AS ProjectName FROM Employees AS e
JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE p.StartDate > '2002-08-13' AND p.EndDate IS NULL
ORDER BY e.EmployeeID

(08)
SELECT e.EmployeeID, FirstName, 
IIF(p.StartDate > '2005-01-01', NULL, p.Name) AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE e.EmployeeID = 24

(09)
SELECT e.EmployeeID, e.FirstName, e.ManagerID, ep.FirstName FROM Employees AS e
JOIN Employees AS ep ON ep.EmployeeID = e.ManagerID
WHERE e.ManagerID IN (3,7)
ORDER BY e.EmployeeID

(10)SELECT TOP 50 e.EmployeeID, e.FirstName + ' ' + e.LastName AS EmployeeName, 
ep.FirstName + ' ' + ep.LastName AS ManagerName, 
d.Name FROM Employees AS e
JOIN Employees as ep ON ep.EmployeeID = e.ManagerID
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
ORDER BY e.EmployeeID

(11)
SELECT TOP 1 AVG(Salary) AS MinAverageSalary
FROM Employees
GROUP BY DepartmentID
ORDER BY MinAverageSalary

(12)
--Use Geography 
SELECT mc.CountryCode, m.MountainRange, p.PeakName, p.Elevation FROM MountainsCountries AS mc
JOIN Mountains AS m ON m.Id = mc.MountainId
JOIN Peaks AS p ON P.MountainId = mc.MountainId
WHERE mc.CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY p.Elevation DESC

(13)
SELECT CountryCode, COUNT(MountainId) AS MountainRanges FROM MountainsCountries
WHERE CountryCode IN ('US', 'RU', 'BG')
GROUP BY CountryCode

(14)
SELECT TOP 5 c.CountryName, r.RiverName
FROM Countries AS c
JOIN Continents AS cont ON cont.ContinentCode = c.ContinentCode
LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
WHERE cont.ContinentName = 'Africa'
ORDER BY c.CountryName

(15)
WITH CCYContUsage_CTE (ContinentCode, CurrencyCode, CurrencyUsage) AS (
  SELECT ContinentCode, CurrencyCode, COUNT(CountryCode) AS CurrencyUsage
  FROM Countries 
  GROUP BY ContinentCode, CurrencyCode
  HAVING COUNT(CountryCode) > 1  
)
SELECT ContMax.ContinentCode, ccy.CurrencyCode, ContMax.CurrencyUsage 
  FROM
  (SELECT ContinentCode, MAX(CurrencyUsage) AS CurrencyUsage
   FROM CCYContUsage_CTE 
   GROUP BY ContinentCode) AS ContMax
JOIN CCYContUsage_CTE AS ccy 
ON (ContMax.ContinentCode = ccy.ContinentCode AND ContMax.CurrencyUsage = ccy.CurrencyUsage)
ORDER BY ContMax.ContinentCode

(16)
SELECT
  COUNT(c.CountryCode) AS CountryCode
FROM Countries AS c
LEFT JOIN MountainsCountries AS m ON c.CountryCode = m.CountryCode
WHERE m.MountainId IS NULL

(17)
SELECT TOP 5 c.CountryName,
  MAX(p.Elevation) AS HighestPeakElevation,
  MAX(r.Length) AS LongestRiverLength
FROM Countries AS c
  LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
  LEFT JOIN Peaks AS p ON p.MountainId = mc.MountainId
  LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
  LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName

(18)
WITH PeaksMountains_CTE (Country, PeakName, Elevation, Mountain) AS (

  SELECT c.CountryName, p.PeakName, p.Elevation, m.MountainRange
  FROM Countries AS c
  LEFT JOIN MountainsCountries as mc ON c.CountryCode = mc.CountryCode
  LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
  LEFT JOIN Peaks AS p ON p.MountainId = m.Id
)

SELECT TOP 5
  TopElevations.Country AS Country,
  ISNULL(pm.PeakName, '(no highest peak)') AS HighestPeakName,
  ISNULL(TopElevations.HighestElevation, 0) AS HighestPeakElevation,	
  ISNULL(pm.Mountain, '(no mountain)') AS Mountain
FROM 
  (SELECT Country, MAX(Elevation) AS HighestElevation
   FROM PeaksMountains_CTE 
   GROUP BY Country) AS TopElevations
LEFT JOIN PeaksMountains_CTE AS pm 
ON (TopElevations.Country = pm.Country AND TopElevations.HighestElevation = pm.Elevation)
ORDER BY Country, HighestPeakName 