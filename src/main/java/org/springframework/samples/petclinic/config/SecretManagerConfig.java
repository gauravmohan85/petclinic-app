package org.springframework.samples.petclinic.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("cloudrun")
public class SecretManagerConfig {

	// Spring Cloud GCP Secret Manager auto-configuration does most of the work
	// This class enables us to conditionally apply this configuration only in cloudrun
	// profile

}