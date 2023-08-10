generateTreatmentModalitiesPathwaysInfo <- function(connection, cohortDatabaseSchema, cohortTable, databaseId) {
  targetCohorts <- read.csv(file.path('inst/settings/CohortsToCreateTarget.csv'))
  pathwaysCohorts <- RJSONIO::fromJSON(paste(readLines(file.path('inst/settings/SettingsTreatmentTypePathways.json')), collapse = ""))
  diagnosisCohortId <- pathwaysCohorts$diagnosisCohort$id
  if(pathwaysCohorts$diagnosisCohort$useStratifiedCohortInAnalysis){
    diagnosisCohortsIds <- c(diagnosisCohortId, 
                             getTargetStrataXref() %>% dplyr::filter(startsWith(as.character(cohortId), '101')) %>% dplyr::pull('cohortId'))
  }
  
  treatmentCohortsIds <- c(107, 108, 110, 111, 112, 113)
  
  sql <- SqlRender::loadRenderTranslateSql(dbms = connection@dbms,
                                           sqlFilename = "GenerateTreatmentTypePathways.sql",
                                           packageName = getThisPackageName(),
                                           warnOnMissingParameters = TRUE,
                                           cohort_database_schema = cohortDatabaseSchema,
                                           cohort_table = cohortTable,
                                           diagnosis_cohort_ids = diagnosisCohortsIds,
                                           treatment_cohorts_ids = paste(treatmentCohortsIds, collapse = ', ')
                                           
  )
  
  result <- DatabaseConnector::querySql(connection, sql)
  colnames(result) <- SqlRender::snakeCaseToCamelCase(colnames(result))
  
  cohortNames <- getTargetStrataXref() %>%
    dplyr::filter(cohortId %in% diagnosisCohortsIds) %>%
    dplyr::select(cohortId, name)
  cohortNames <- rbind(
    cohortNames, data.frame(
      cohortId = pathwaysCohorts$diagnosisCohort$id, 
      name = targetCohorts %>% dplyr::filter(cohortId == diagnosisCohortId) %>% dplyr::pull(atlasName))
  ) 
  
  result %>% 
    dplyr::left_join(cohortNames, by = c('sourceId' = 'cohortId')) %>% 
    dplyr::rename(sourceName = name) %>% 
    dplyr::left_join(targetCohorts, by = c('targetId' = 'cohortId')) %>% 
    dplyr::select(sourceId, sourceName, atlasName, sourceId, targetId, value) %>% 
    dplyr::mutate(atlasName = stringr::str_to_title(stringr::str_replace(atlasName, '\\[[\\w ]+\\][ \\w]+initiated ', ''))) %>% 
    dplyr::mutate(sourceName = stringr::str_replace_all(sourceName, '\\[[\\w ]+\\] ', '')) %>% 
    dplyr::mutate(databaseId = databaseId) %>% 
    tidyr::replace_na(list(atlasName = "No matching subject")) %>% 
    dplyr::rename(targetName = atlasName)
}
