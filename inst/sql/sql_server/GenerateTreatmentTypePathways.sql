SELECT cohort_definition_id AS source_id, target_cohort_id AS target_id, count(*) AS value
FROM (
     SELECT coh.*, coalesce(coh2.cohort_definition_id, -100) AS target_cohort_id
     FROM @cohort_database_schema.@cohort_table coh
     LEFT JOIN @cohort_database_schema.@cohort_table coh2
         ON coh.subject_id = coh2.subject_id
             AND coh2.cohort_definition_id IN (@treatment_cohorts_ids)
     ) tab
WHERE cohort_definition_id IN (@diagnosis_cohort_ids)
GROUP BY cohort_definition_id, target_cohort_id
ORDER BY cohort_definition_id, target_cohort_id;
