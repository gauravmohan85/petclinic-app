package org.springframework.samples.petclinic.system;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthCheckController {

    @Value("${GCP_REGION:unknown}")
    private String region;

    @Value("${FAIL_REGION:none}")
    private String failRegion;

    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        // If we're in the region we want to fail
        if (failRegion != null && !failRegion.equals("none") && failRegion.equals(region)) {
            return ResponseEntity.status(500).body("Simulated failure in region: " + region);
        }
        
        return ResponseEntity.ok("Service healthy in region: " + region);
    }
    
    // Helper method to get current region (used for logging/debugging)
    private String getCurrentRegion() {
        return region;
    }
}