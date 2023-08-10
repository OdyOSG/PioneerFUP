library(Andromeda)
library(dplyr)

folderName <- 'C:\\Users\\Artem\\R_studies_results\\PIONEER_Treatment_v4.0'
files <- list.files(folderName, pattern = "\\.zip$")

if (length(files) == 0) {
  stop("No study resuls found in specified path")
}

studyResults <- loadAndromeda(file.path(folderName, files[1]))
# bug_fix
dbId <- (studyResults$database %>% select(databaseId) %>% collect())[[1]]
studyResults$metrics_distribution <- studyResults$metrics_distribution %>% mutate(databaseId = dbId)

n <- names(studyResults)
n <- n[!n %in% c('cohort', 'covariate')]
# n <- 'cohort_time_to_event'

for (file in files[-1]) {
  andrData <- loadAndromeda(file.path(folderName, file))
  # bug fix (forgot to add databaseId field to `metrics_distribution`. Should be fixed later)
  dbId <- (andrData$database %>% select(databaseId) %>% collect())[[1]]
  andrData$metrics_distribution <- andrData$metrics_distribution %>% mutate(databaseId = dbId)
  
  for (name in n) {
    appendToTable(studyResults[[name]], andrData[[name]])
  }

  close(andrData)
  rm(andrData)
}

saveAndromeda(studyResults, file.path(folderName, 'study_results.zip'))


# library(Andromeda)
# df1 <- andromeda(tab = data.frame(x = runif(4000000), y = runif(4000000), 
#                                   xx = runif(4000000), yy = runif(4000000), 
#                                   xxx = runif(4000000), yyy = runif(4000000)))
# df2 <- andromeda(tab = data.frame(x = runif(4000000), y = runif(4000000),
#                                   xx = runif(4000000), yy = runif(4000000),
#                                   xxx = runif(4000000), yyy = runif(4000000)))
# appendToTable(df1[['tab']], df2[['tab']])






library(Andromeda)
folderName <- 'C:\\Users\\Artem\\R_studies_results\\PIONEER_Treatment_v4.0'
files <- list.files(folderName, pattern = "\\.zip$")
studyResults <- loadAndromeda(file.path(folderName, files[1]))
andrData <- loadAndromeda(file.path(folderName, files[2]))


a <- andromeda(tte = studyResults$cohort_time_to_event)
a$cv <- studyResults$covariate_value


b <- andromeda(tte = andrData$cohort_time_to_event)
b$cv <- andrData$covariate_value


appendToTable(a[['cv']], b[['cv']])
appendToTable(a[['tte']], b[['tte']])




