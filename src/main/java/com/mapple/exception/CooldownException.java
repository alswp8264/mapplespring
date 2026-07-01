package com.mapple.exception;

public class CooldownException extends RuntimeException {
    public CooldownException(String message) {
        super(message);
    }
}
