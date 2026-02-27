package com.example.oceanviewresort.util;

import com.example.oceanviewresort.dao.ReservationDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Background scheduler that automatically expires reservations whose
 * check-out date has passed:
 *   - Sets reservation status → 'checked_out'
 *   - Sets the assigned room status → 'available'
 *
 * Runs once at server startup and then every 5 minutes.
 */
@WebListener
public class RoomStatusScheduler implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(
            () -> {
                try {
                    new ReservationDAO().expireCheckedOut();
                } catch (Exception e) {
                    System.err.println("[RoomStatusScheduler] error: " + e.getMessage());
                }
            },
            0,          // run immediately on startup
            5,          // then repeat every 5 minutes
            TimeUnit.MINUTES
        );
        System.out.println("[RoomStatusScheduler] Started – checking expired reservations every 5 minutes.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            System.out.println("[RoomStatusScheduler] Stopped.");
        }
    }
}
