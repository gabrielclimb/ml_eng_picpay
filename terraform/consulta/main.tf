# glue
resource "aws_glue_crawler" "crawler_cleaned_data" {
  database_name = aws_glue_catalog_database.db_beer.name
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

resource "aws_glue_catalog_database" "db_beer" {
  name = "db_beer"
}

resource "aws_glue_catalog_table" "table_data_beer" {
  name          = "table_data_beer"
  database_name = aws_glue_catalog_database.db_beer.name

  description = "Table data beer"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL       = "TRUE"
    classification = "CSV"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_cleaned_data}/tb_data_beer_cleaned"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "data_beer"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
      #   SerializationLibrary: org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe

      parameters = {
        "serialization.format" = 1,
        "field.delim"          = ","
      }
    }

    columns {
      name = "id"
      type = "double"
    }

    columns {
      name    = "name"
      type    = "string"
      comment = "beer name"
    }

    columns {
      name    = "abv"
      type    = "double"
      comment = "alcohol by volume"
    }

    columns {
      name    = "ibu"
      type    = "double"
      comment = "international bittering unit"
    }

    columns {
      name    = "target_fg"
      type    = "double"
      comment = "target final gravity"
    }

    columns {
      name    = "target_og"
      type    = "double"
      comment = "target original gravity"
    }

    columns {
      name    = "ebc"
      type    = "double"
      comment = "European Brewery Convention, color scale"
    }

    columns {
      name    = "srm"
      type    = "double"
      comment = "Standard Reference Method, color scale"
    }

    columns {
      name    = "ph"
      type    = "double"
      comment = "how acid it's"
    }
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
