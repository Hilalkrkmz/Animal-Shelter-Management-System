package com.example.barinakys.controller;

import com.example.barinakys.service.DatabaseManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class BarinakController {

    @Autowired
    private DatabaseManager dbManager;

    @GetMapping("/")
    public String anaSayfa(Model model) {
        model.addAttribute("toplamHayvan", dbManager.toplamHayvanSayisi());
        model.addAttribute("aktifBasvuru", dbManager.fn_AktifBasvuruSay());
        model.addAttribute("hayvanlar", dbManager.hayvanListesiGetir());
        return "index";
    }
    @PostMapping("/ekle")
    public String ekle(@RequestParam String ad, @RequestParam String tur, @RequestParam int yas,
                       @RequestParam String cinsiyet, @RequestParam String cins,
                       @RequestParam String saglik, @RequestParam String foto,
                       RedirectAttributes redirectAttributes) {
        try {
            dbManager.hayvanEkle(ad, tur, yas, cinsiyet, cins, saglik, foto);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("hataMesaji", "⚠️ EKLEME HATASI: " + hataTemizle(e.getMessage()));
        }
        return "redirect:/";
    }
    @PostMapping("/sil")
    public String sil(@RequestParam int id, RedirectAttributes redirectAttributes) {
        try {
            dbManager.hayvanSil(id);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("hataMesaji", "⚠️ SİLME HATASI: " + hataTemizle(e.getMessage()));
        }
        return "redirect:/";
    }

    @PostMapping("/sahiplendir")
    public String sahiplendir(@RequestParam int id) {
        dbManager.sp_SahiplendirmeTamamla(id);
        return "redirect:/";
    }

    @PostMapping("/guncelle")
    public String guncelle(@RequestParam int id, @RequestParam String ad,
                           @RequestParam int yas, @RequestParam String saglik) {
        dbManager.hayvanGuncelle(id, ad, yas, saglik);
        return "redirect:/";
    }

    private String hataTemizle(String raw) {
        if (raw == null) return "İşlem başarısız.";
        if (raw.contains("Barınak kapasitesi dolu"))
            return "⚠️ KAPASİTE HATASI: Barınak şu an tam dolu, yeni hayvan kabul edilemiyor!";
        if (raw.contains("Sahiplendirilmiş hayvan silinemez"))
            return "🚫 SİLME REDDEDİLDİ: Bu hayvanın sahiplendirme belgesi düzenlendiği için sistemden silinemez.";
        if (raw.contains("violates foreign key constraint"))
            return "❌ İLİŞKİ HATASI: Bu hayvana bağlı tıbbi veya bakım kayıtları olduğu için silme işlemi engellendi.";
        return "İşlem veritabanı kuralları (Trigger/Constraint) nedeniyle durduruldu.";    }
}