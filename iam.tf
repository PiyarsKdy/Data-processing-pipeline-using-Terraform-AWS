resource "aws_iam_role_policy" "s3_policy" {
  name   = "s3_policy"
  role   = aws_iam_role.aws-demo.id
  policy = "${file("s3-policy.json")}"
}

resource "aws_iam_role_policy" "glue_policy" {
  name   = "glue_policy"
  role   = aws_iam_role.aws-demo.id
  policy = "${file("glue-policy.json")}"
}

resource "aws_iam_role_policy" "athena_policy" {
  name   = "athena_policy"
  role   = aws_iam_role.aws-demo.id
  policy = "${file("athena-policy.json")}"
}

resource "aws_iam_role" "aws-demo" {
  name  = "aws-demo"
  assume_role_policy = "${file("assume-policy.json")}"
}