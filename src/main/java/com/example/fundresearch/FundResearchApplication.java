package com.example.fundresearch;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.example.fundresearch.mapper")
public class FundResearchApplication {
    public static void main(String[] args) {
        SpringApplication.run(FundResearchApplication.class, args);
    }
}

