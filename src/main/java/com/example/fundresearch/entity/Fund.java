package com.example.fundresearch.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.util.Date;

@Data
@TableName("fund_info")
public class Fund {
    private Long id;
    private String code;
    private String name;
    private String type;
    private BigDecimal scale;
    private Date establishDate;
    private Long companyId;
    private Long managerId;
    private String riskLevel;
    private String benchmark;
    private String attributionText;
}



