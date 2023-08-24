generateTreatmentModalitiesTimeToEventInfo <- function(connection, cohortDatabaseSchema, cohortTable, databaseId) {
  targetCohorts <- read.csv(file.path('inst/settings/CohortsToCreateTarget.csv'))
  pathwaysCohorts <- RJSONIO::fromJSON(paste(readLines(file.path('inst/settings/SettingsTreatmentTypePathways.json')), collapse = ""))
  diagnosisCohortId <- pathwaysCohorts$diagnosisCohort$id
  if(pathwaysCohorts$diagnosisCohort$useStratifiedCohortInAnalysis){
    diagnosisCohortsIds <- c(diagnosisCohortId, 
                             getTargetStrataXref() %>% dplyr::filter(startsWith(as.character(cohortId), '101')) %>% dplyr::pull('cohortId'))
  }
  
  treatmentCohortsIds <- read.csv(file.path('inst/settings/CohortsToCreateModality.csv')) %>%
    dplyr::mutate(eventId = name) %>%
    dplyr::rename('outcomeCohortIds' = 'name', 'name' = 'atlasName') %>% 
    dplyr::select(outcomeCohortIds, name, eventId)
  allModalitiesIds <- treatmentCohortsIds %>% dplyr::pull(outcomeCohortIds)
  treatmentCohortsIds <- rbind(treatmentCohortsIds,
                               data.frame(outcomeCohortIds = paste(allModalitiesIds, collapse = ', '),
                                          name = 'Any modality',
                                          eventId = max(allModalitiesIds) + 1)
  )
  
  timeToTreatmentModality <- generateSurvival(connection = connection,
                                              cohortDatabaseSchema = cohortDatabaseSchema,
                                              cohortTable = cohortTable,
                                              targetIds = diagnosisCohortsIds,
                                              events = treatmentCohortsIds,
                                              databaseId = databaseId,
                                              packageName = getThisPackageName())
  return(timeToTreatmentModality)
  
}


