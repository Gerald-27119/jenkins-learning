package org.example.jenkins;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class MessagePrinter {

    private String message = "Hi, how are you?";

    @Scheduled(fixedRate = 5000)
    public void printMessage() {
        System.out.println(message);
    }
}
