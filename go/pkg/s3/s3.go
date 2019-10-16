package s3

import (
	"bytes"
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

func createServiceClient() *s3.S3 {
	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String(endpoints.ApNortheast1RegionID),
	}))

	return s3.New(sess)
}

// CheckKey return error
func CheckKey(bucket, key string) error {
	svc := createServiceClient()

	_, err := svc.GetObject(&s3.GetObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
	})

	if err != nil {
		return err
	}

	return nil
}

// Upload return error
func Upload(buf bytes.Buffer, bucket, key string) error {
	svc := createServiceClient()

	_, errpo := svc.PutObject(&s3.PutObjectInput{
		Body:                 bytes.NewReader(buf.Bytes()),
		Bucket:               aws.String(bucket),
		Key:                  aws.String(key),
		ACL:                  aws.String("private"),
		ServerSideEncryption: aws.String("AES256"),
	})

	if errpo != nil {
		if aerr, ok := errpo.(awserr.Error); ok {
			log.Printf("aws error %v at PutObject", aerr.Error())
			return aerr
		}
		log.Printf("error %v at PutObject", errpo.Error())
		return errpo
	}

	return nil
}
