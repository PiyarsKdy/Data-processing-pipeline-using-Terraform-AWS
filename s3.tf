resource "aws_s3_bucket" "s3bucket" {
  bucket = "piyars-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "source_data_folder" {
  bucket = aws_s3_bucket.s3bucket.id
  key    = "source-data/"
}

resource "aws_s3_object" "destination_data_folder" {
  bucket = aws_s3_bucket.s3bucket.id
  key    = "destination-data/"
}

resource "aws_s3_object" "query_folder" {
  bucket = aws_s3_bucket.s3bucket.id
  key    = "query/"
}

resource "aws_s3_object" "scripts_folder" {
  bucket = aws_s3_bucket.s3bucket.id
  key    = "scripts/"
}

resource "aws_s3_object" "ctas_folder" {
  bucket = aws_s3_bucket.s3bucket.id
  key    = "ctas_table/"
}

resource "aws_s3_object" "upload_jar_file" { 
    bucket = aws_s3_bucket.s3bucket.id 
    key = "delta-hive-assembly_2.12-3.1.0.jar" 
    source = "C:\\Users\\Admin\\Desktop\\office\\forwood-etl\\delta-hive-assembly_2.12-3.1.0.jar" 
}


resource "aws_s3_object" "upload_glue_script" { 
    bucket = aws_s3_bucket.s3bucket.id 
    key = "scripts/glue-script.py" 
    source = "C:\\Users\\Admin\\Desktop\\office\\forwood-etl\\monday\\glue-script.py"
}