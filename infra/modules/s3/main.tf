resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  # Standard tagging block
  tags = merge(
    var.tags,
    {
      Name = "ProductS3Bucket"
    }
  )
}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  # Only create this policy if we actually have a CloudFront ARN
  count  = var.cloudfront_arn != null ? 1 : 0 
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.allow_cloudfront[0].json
}

data "aws_iam_policy_document" "allow_cloudfront" {
  count = var.cloudfront_arn != null ? 1 : 0
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.cloudfront_arn]
    }
  }
}

