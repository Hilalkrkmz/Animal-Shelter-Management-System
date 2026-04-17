package com.example.barinakys.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Map;

@Service
public class DatabaseManager {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<Map<String, Object>> hayvanListesiGetir() {
        String sql = "SELECT * FROM hayvan ORDER BY hayvanid ASC";
        return jdbcTemplate.queryForList(sql);
    }
    public Integer toplamHayvanSayisi() {
        return jdbcTemplate.queryForObject("SELECT COUNT(*) FROM public.hayvan", Integer.class);
    }

    @Transactional
    public void hayvanSil(int id) {
        jdbcTemplate.update("DELETE FROM hayvan WHERE hayvanid = ?", id);
    }
    @Transactional
    public void hayvanGuncelle(int id, String ad, int yas, String saglik) {
        String sql = "UPDATE public.hayvan SET ad = ?, yas = ?, saglikdurumu = ? WHERE hayvanid = ?";
        jdbcTemplate.update(sql, ad, yas, saglik, id);
    }

    @Transactional
    public void hayvanEkle(String ad, String tur, int yas, String cinsiyet, String cins, String saglik, String fotoUrl) {
        String sql = "INSERT INTO public.hayvan (ad, tur, yas, cinsiyet, cins, giristarihi, saglikdurumu, fotograf, durum, barinakid) " +
                "VALUES (?, ?, ?, ?, ?, CURRENT_DATE, ?, ?, 'Barınakta', 1)";
        jdbcTemplate.update(sql, ad, tur, yas, cinsiyet, cins, saglik, fotoUrl);
    }

    @Transactional
    public void sp_SahiplendirmeTamamla(int hayvanId) {
        jdbcTemplate.execute(String.format("CALL public.sp_SahiplendirmeTamamla(5, %d, 1, 2)", hayvanId));
    }

    public Integer fn_AktifBasvuruSay() {
        return jdbcTemplate.queryForObject("SELECT public.fn_AktifBasvuruSay()", Integer.class);
    }
}