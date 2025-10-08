package org.sorokin;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Random;

public class DataGenerator
{
        private static final String DB_URL = "jdbc:postgresql://localhost:5432/postgres"; // <-- ИЗМЕНИТЬ!
        private static final String DB_USER = "postgres";
        private static final String DB_PASSWORD = "admin";

        private static final int NUM_CUSTOMERS = 1000;
        private static final int NUM_PRODUCTS = 100;
        private static final int DAYS_RANGE = 425;
        private static final int BATCH_SIZE = 5000;
        private static final int TOTAL_ORDERS = 40_000_000;

        private static final Random random = new Random();

        public static void main(String[] args) {
        System.out.println("Запуск генерации. Цель: " + TOTAL_ORDERS + " заказов.");
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            conn.setAutoCommit(false);
            insertInitialData(conn);
            long startTime = System.currentTimeMillis();
            insertOrders(conn);
            long endTime = System.currentTimeMillis();

            System.out.println("\nГенерация завершена. Всего вставлено " + TOTAL_ORDERS + " строк.");
            System.out.println("Общее время: " + (endTime - startTime) / 1000.0 + " секунд.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

        private static void insertInitialData(Connection conn) throws SQLException {
        String sqlProducts = "INSERT INTO sql_plus_project.products (name, price) " +
                "SELECT 'Product_' || generate_series(1, 100), (random() * 1000 + 1)::NUMERIC(10, 2)";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlProducts)) {
            pstmt.executeUpdate();
            System.out.println("Вставлено 100 продуктов.");
        }

        String sqlCustomers = "INSERT INTO sql_plus_project.customers (name, email) " +
                "SELECT 'Customer_' || generate_series(1, 1000), 'user' " +
                "|| generate_series(1, 1000) || '@example.com'";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlCustomers)) {
            pstmt.executeUpdate();
            System.out.println("Вставлено 1000 клиентов.");
        }
        conn.commit();
    }

        private static void insertOrders(Connection conn) throws SQLException {
        String insertSQL = "INSERT INTO sql_plus_project.orders " +
                "(customer_id, product_id, created_at, quantity, amount, status)" +
                " VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {
            for (int i = 1; i <= TOTAL_ORDERS; i++) {
                int customerId = random.nextInt(NUM_CUSTOMERS) + 1;
                int productId = random.nextInt(NUM_PRODUCTS) + 1;
                long now = System.currentTimeMillis();
                long randomTime = now - (long) (random.nextDouble() * DAYS_RANGE * 24 * 60 * 60 * 1000L);
                java.sql.Timestamp createdAt = new java.sql.Timestamp(randomTime);
                int quantity = random.nextInt(10) + 1;
                double amount = random.nextDouble() * 5000 + 10;
                String status = random.nextDouble() < 0.9 ? "COMPLETED" : "NEW";
                pstmt.setInt(1, customerId);
                pstmt.setInt(2, productId);
                pstmt.setTimestamp(3, createdAt);
                pstmt.setInt(4, quantity);
                pstmt.setDouble(5, amount);
                pstmt.setString(6, status);

                pstmt.addBatch();

                if (i % BATCH_SIZE == 0) {
                    pstmt.executeBatch();
                    conn.commit();
                    System.out.print("Вставлено: " + i + " строк.\r");
                }
            }

            pstmt.executeBatch();
            conn.commit();
        }
    }
}
