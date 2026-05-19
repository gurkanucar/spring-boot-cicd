package com.gucardev.springbootcicd;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
public class InstanceController {

    @GetMapping("/whoami")
    public Map<String, String> whoami() {
        Map<String, String> info = new LinkedHashMap<>();
        info.put("hostname", hostname());
        info.put("taskSlot", envOrDefault("TASK_SLOT", "n/a"));
        return info;
    }

    private String hostname() {
        try {
            return InetAddress.getLocalHost().getHostName();
        } catch (UnknownHostException e) {
            return envOrDefault("HOSTNAME", "unknown");
        }
    }

    private String envOrDefault(String key, String fallback) {
        String value = System.getenv(key);
        return (value == null || value.isBlank()) ? fallback : value;
    }
}
