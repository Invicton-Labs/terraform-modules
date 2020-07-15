// A role for the S3 buckets to use to do cross-region replication
resource "aws_iam_role" "s3-replicator" {
  provider           = aws.primary
  name               = "S3Replicator-${var.name_prefix}"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "s3.amazonaws.com"
            }
        }
    ]
}
POLICY
}

data "aws_iam_policy_document" "s3-replicate-policy" {
  statement {
    actions = [
      "s3:Get*",
      "s3:ListBucket"
    ]
    resources = [
      local.primary_bucket_arn,
      "${local.primary_bucket_arn}/*"
    ]
  }
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetObjectVersionTagging"
    ]
    resources = ["${local.secondary_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "replication" {
  provider = aws.primary
  role     = aws_iam_role.s3-replicator.name
  policy   = data.aws_iam_policy_document.s3-replicate-policy.json
}
