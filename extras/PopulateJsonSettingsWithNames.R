library('RJSONIO')
library('dplyr')

# populate Treatment Type Pathways json file

targetCohorts <- read.csv(file.path('inst/settings/CohortsToCreateTarget.csv'))

pathwaysCohorts <- fromJSON(paste(readLines(file.path('inst/settings/SettingsTreatmentTypePathways.json')), collapse = ""))
pathwaysCohorts$diagnosisCohort$name <- targetCohorts %>% filter(name == pathwaysCohorts$diagnosisCohort$id) %>% pull(atlasName)

for (i in 1:length(pathwaysCohorts$treatmentCohorts)){
  id = pathwaysCohorts$treatmentCohorts[i][[1]]$id
  pathwaysCohorts$treatmentCohorts[i][[1]]$name = targetCohorts %>% 
                                                   filter(name == id) %>%
                                                   pull(atlasName)
 }


write(toJSON(pathwaysCohorts, pretty = TRUE), file.path('inst/settings/SettingsTreatmentTypePathways.json'))
