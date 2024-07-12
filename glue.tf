resource "aws_glue_job" "piyars_glue_script" {
  name         = "piyars-glue"
  description  = "Glue script for data processing"
  role_arn     = aws_iam_role.aws-demo.arn
  worker_type = "G.1X"
  number_of_workers = 4
  max_retries = 1
  execution_class = "STANDARD"

  command {
    script_location = "s3://${aws_s3_object.upload_glue_script.bucket}/${aws_s3_object.upload_glue_script.key}"
    python_version  = "3"
  }
  default_arguments = {
    "--extra-jars" = "s3://${aws_s3_object.upload_jar_file.bucket}/${aws_s3_object.upload_jar_file.key}"
    "--datalake-formats" = "delta"
    "--DB_NAME" = aws_glue_catalog_database.piyars_db.name
    "--TABLE_NAME" = aws_glue_catalog_table.tier1_table.name
    "--JOB_NAME" = "gluejob"
    "--enable-job-insights" = "true"
    "--job-bookmark-option" = "job-bookmark-enable"
    "--job-language" = "python"
  }

}


# bookmark must be enabled manually.