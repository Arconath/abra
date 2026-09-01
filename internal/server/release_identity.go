package server

import (
	"os"
	"strings"

	internalversion "github.com/Arconath/abra/internal/version"
)

func releaseIdentityReady() bool {
	environment := strings.ToLower(strings.TrimSpace(os.Getenv("NODE_ENV")))
	if environment != "production" && environment != "staging" {
		return true
	}
	return immutableReleaseVersion(internalversion.Commit) && immutableImageDigest(os.Getenv("IMAGE_DIGEST"))
}

func immutableReleaseVersion(value string) bool {
	value = strings.TrimSpace(value)
	if len(value) != len("sha-")+40 || !strings.HasPrefix(value, "sha-") {
		return false
	}
	return lowerHex(value[len("sha-"):])
}

func immutableImageDigest(value string) bool {
	value = strings.TrimSpace(value)
	if len(value) != len("sha256:")+64 || !strings.HasPrefix(value, "sha256:") {
		return false
	}
	return lowerHex(value[len("sha256:"):])
}

func lowerHex(value string) bool {
	if value == "" {
		return false
	}
	for _, character := range value {
		if !(character >= '0' && character <= '9') && !(character >= 'a' && character <= 'f') {
			return false
		}
	}
	return true
}
