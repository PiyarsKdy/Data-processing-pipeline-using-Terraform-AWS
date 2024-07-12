resource "aws_glue_catalog_database" "piyars_db" {
  name = "piyars-db"
}

resource "aws_glue_catalog_table" "tier1_table" {
  name          = "tier1-table"
  database_name = aws_glue_catalog_database.piyars_db.name

  storage_descriptor {
    location      = "s3://${aws_s3_object.source_data_folder.bucket}/${aws_s3_object.source_data_folder.key}"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet-serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "forwoodmetadata"
      type = "struct<tenantId:string,env:string,eventType:string,crmEventId:string>"
    }

    columns {
      name = "eventpayload"
      type = "struct<data:string>"
    }
  }
}


resource "aws_glue_catalog_table" "tier2_table" {
  name          = "tier2-table"
  database_name = aws_glue_catalog_database.piyars_db.name

  parameters = {
    EXTERNAL              = "TRUE"
    "manifest_location" = "s3://${aws_s3_object.destination_data_folder.bucket}/${aws_s3_object.destination_data_folder.key}/_symlink_format_manifest/manifest"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_object.destination_data_folder.bucket}/${aws_s3_object.destination_data_folder.key}"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      parameters  = {"serialization.format" = 1}
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "checklist_nid"
      type = "string"
    }

    columns {
      name = "checklist_vid"
      type = "string"
    }

    columns {
      name = "verification_type"
      type = "string"
    }

    columns {
      name = "nid"
      type = "string"
    }

    columns {
      name = "verification_date"
      type = "string"
    }
  }
}

