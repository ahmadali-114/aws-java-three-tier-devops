package com.dpt.demo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfiguration {

	@Bean
	SecurityFilterChain applicationSecurity(HttpSecurity http) throws Exception {
		http
			.authorizeRequests()
				.antMatchers("/", "/home", "/login", "/register").permitAll()
				.anyRequest().denyAll()
				.and()
			.formLogin().disable()
			.httpBasic().disable();

		return http.build();
	}
}
