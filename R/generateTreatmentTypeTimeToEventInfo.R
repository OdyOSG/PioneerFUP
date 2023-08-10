generateTreatmentTypeTimeToEventInfo <- function(connection, cohortDatabaseSchema, cohortTable, databaseId) {
  targetCohorts <- read.csv(file.path('inst/settings/CohortsToCreateTarget.csv'))
  pathwaysCohorts <- RJSONIO::fromJSON(paste(readLines(file.path('inst/settings/SettingsTreatmentTypePathways.json')), collapse = ""))
  diagnosisCohortId <- pathwaysCohorts$diagnosisCohort$id
  if(pathwaysCohorts$diagnosisCohort$useStratifiedCohortInAnalysis){
    diagnosisCohortsIds <- c(diagnosisCohortId, 
                             getTargetStrataXref() %>% dplyr::filter(startsWith(as.character(cohortId), '101')) %>% dplyr::pull('cohortId'))
  }
  
  treatmentCohortsIds <- rbindlist(pathwaysCohorts$treatmentCohorts) %>%
    # dplyr::mutate(eventId = dplyr::row_number()) %>%
    dplyr::mutate(eventId = id) %>%
    dplyr::rename('outcomeCohortIds' = 'id')
  
  timeToTreatmentType <- generateSurvival(connection = connection,
                                          cohortDatabaseSchema = cohortDatabaseSchema,
                                          cohortTable = cohortTable,
                                          targetIds = diagnosisCohortsIds,
                                          events = treatmentCohortsIds,
                                          databaseId = databaseId,
                                          packageName = getThisPackageName())
  return(timeToTreatmentType)
  
}
