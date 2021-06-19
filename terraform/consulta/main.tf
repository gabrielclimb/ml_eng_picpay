# glue
resource "aws_glue_crawler" "crawler_cleaned_data" {
  database_name = aws_glue_catalog_database.glue_catalog_databeer.name
  name          = "crawler_cleaned_data"
  role          = aws_iam_role.aws_glue_crawler.arn

  schedule = "cron(0/5 * * * ? *)"

  configuration = jsonencode(
    {
      Grouping = {
        TableGroupingPolicy = "CombineCompatibleSchemas"
      }
      Version = 1
    }
  )

  s3_target {
    path = "s3://${var.s3_bucket_cleaned_data}/tb_data_beer_cleaned"
  }
}

resource "aws_glue_catalog_database" "glue_catalog_databeer" {
  name = "cleaned_data_beer"
}

resource "aws_glue_catalog_table" "table" {
  name          = "logs"
  database_name = aws_glue_catalog_database.glue_catalog_databeer.name

  description = "Table data beer"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL       = "TRUE"
    classification = "CSV"
  }
}

# roles
resource "aws_iam_role" "aws_glue_crawler" {
  name = "aws_glue_crawler"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "glue.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  inline_policy {
    name = "full_acces"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "cloudwatch:*",
            "s3:*",
            "glue:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}
