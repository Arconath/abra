package server

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestRemovedBrowserUIReturnsNotFound(t *testing.T) {
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/app/", nil)

	removedBrowserUI(rec, req)

	if rec.Code != http.StatusNotFound {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusNotFound)
	}
	if !strings.Contains(rec.Body.String(), "browser_ui_not_shipped") {
		t.Fatalf("body = %q, want browser_ui_not_shipped", rec.Body.String())
	}
}

func TestIndexDoesNotAdvertiseRESTCatalog(t *testing.T) {
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/", nil)

	(&handler{}).index(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
	var body map[string]any
	if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode body: %v", err)
	}
	if _, ok := body["endpoints"]; ok {
		t.Fatalf("index should not advertise REST endpoint catalog: %v", body["endpoints"])
	}
	if body["product_surface"] != "mcp" || body["mcp"] != "POST /mcp" {
		t.Fatalf("index should advertise MCP as product surface, got %v", body)
	}
}

func TestVersionExposesBuildIdentity(t *testing.T) {
	digest := "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	t.Setenv("IMAGE_DIGEST", digest)
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/version", nil)

	(&handler{}).version(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
	var body map[string]string
	if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode body: %v", err)
	}
	for _, field := range []string{"service", "version", "commit", "build_date", "image_digest"} {
		if body[field] == "" {
			t.Fatalf("version response field %q is empty: %v", field, body)
		}
	}
	if body["service"] != "abra" {
		t.Fatalf("service = %q, want abra", body["service"])
	}
	if body["image_digest"] != digest {
		t.Fatalf("image_digest = %q, want %q", body["image_digest"], digest)
	}
}

func TestProductionReadinessFailsClosedWithoutReleaseIdentity(t *testing.T) {
	t.Setenv("NODE_ENV", "production")
	t.Setenv("IMAGE_DIGEST", "unavailable")
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/readyz", nil)

	(&handler{}).ready(rec, req)

	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusServiceUnavailable)
	}
	if !strings.Contains(rec.Body.String(), "release_identity_unavailable") {
		t.Fatalf("body = %q, want release identity failure", rec.Body.String())
	}
}

func TestIndexDoesNotCatchUnknownRoutes(t *testing.T) {
	for _, path := range []string{
		"/brain/review?scope=repo:test",
		"/brain/traces/trace-123",
		"/brain/eval-runs?scope=repo:test",
	} {
		rec := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, path, nil)

		(&handler{}).index(rec, req)

		if rec.Code != http.StatusNotFound {
			t.Fatalf("%s status = %d, want %d; body=%s", path, rec.Code, http.StatusNotFound, rec.Body.String())
		}
	}
}
