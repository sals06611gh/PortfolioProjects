
IF EXISTS(SELECT 1 FROM sys.views WHERE NAME ='PercentPopulationVaccinated ' AND TYPE='v')
	DROP VIEW PercentPopulationVaccinated ;
GO


--Create view to store data for later vizualizations
CREATE VIEW PercentPopulationVaccinated 
AS 
SELECT cd.continent
,cd.location
,cd.date
,cd.population
,cv.new_vaccinations
,SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd
INNER JOIN CovidVaccinations cv ON cd.location = cv.location
															  AND cd.date = cv.date
WHERE 1 = 1
AND cd.continent IS NOT NULL
--Testing
--AND cd.location = 'Canada'
--Testing


GO