--
-- PostgreSQL database dump
--

\restrict BsuFNhU4mC4jc8SfMtJnejhHl7NYy7LLZB2sgCdh3bVe70w6rhbfy8ipINfcaSM

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-04-18 00:52:52

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 17453)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 267 (class 1255 OID 18628)
-- Name: fn_aktifbasvurusay(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_aktifbasvurusay() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_sayac INT;
BEGIN
    SELECT COUNT(*)
    INTO v_sayac
    FROM Basvuru
    WHERE durum IN ('Beklemede', 'İncelemede');

    RETURN v_sayac;
END;
$$;


ALTER FUNCTION public.fn_aktifbasvurusay() OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 18625)
-- Name: fn_barinakdolulukorani(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_barinakdolulukorani(p_barinakid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_kapasite INT;
    v_dolu INT;
    v_oran DECIMAL(5,2);
BEGIN
    -- Barınağın kapasitesi
    SELECT kapasite
    INTO v_kapasite
    FROM Barinak
    WHERE barinakID = p_barinakID;

    -- Barınaktaki hayvan sayısı
    SELECT COUNT(*)
    INTO v_dolu
    FROM Hayvan
    WHERE barinakID = p_barinakID;

    -- Doluluk oranı hesaplama
    IF v_kapasite > 0 THEN
        v_oran := (v_dolu::DECIMAL / v_kapasite) * 100;
    ELSE
        v_oran := 0;
    END IF;

    RETURN ROUND(v_oran, 2);
END;
$$;


ALTER FUNCTION public.fn_barinakdolulukorani(p_barinakid integer) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 18765)
-- Name: fn_detaylibarinakraporu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_detaylibarinakraporu() RETURNS TABLE(h_id integer, ad text, tur_cins text, saglik text, sorumlu_veteriner text, sahiplendirme_bilgisi text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.hayvanID::INT,
        h.ad::TEXT,
        (h.tur || ' / ' || h.cins)::TEXT,
        h.saglikDurumu::TEXT,
        COALESCE(v.adSoyad, 'Yok')::TEXT,
        COALESCE(s.bilgi, 'Sahiplendirilmedi')::TEXT
    FROM Hayvan h
    LEFT JOIN SaglikKaydi sk ON h.hayvanID = sk.hayvanID
    LEFT JOIN Veteriner v ON sk.veterinerID = v.veterinerID
    LEFT JOIN Basvuru b ON b.basvuruID = b.basvuruID
    LEFT JOIN S_Belgesi s ON s.basvuruID = b.basvuruID;
END;
$$;


ALTER FUNCTION public.fn_detaylibarinakraporu() OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 18626)
-- Name: fn_hayvanbakimsayisi(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_hayvanbakimsayisi(p_hayvanid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_bakim_sayisi INT;
    v_saglik_sayisi INT;
BEGIN
    -- Bakım kayıtlarının sayısı
    SELECT COUNT(*)
    INTO v_bakim_sayisi
    FROM BakimKaydi
    WHERE hayvanID = p_hayvanID;

    -- Sağlık kayıtlarının sayısı
    SELECT COUNT(*)
    INTO v_saglik_sayisi
    FROM SaglikKaydi
    WHERE hayvanID = p_hayvanID;

    -- Toplam işlem sayısı
    RETURN v_bakim_sayisi + v_saglik_sayisi;
END;
$$;


ALTER FUNCTION public.fn_hayvanbakimsayisi(p_hayvanid integer) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 18627)
-- Name: fn_kullanicihayvanlari(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_kullanicihayvanlari(p_sahipid integer) RETURNS TABLE(hayvanid integer, hayvan_adi character varying, turu character varying, yasi integer, cinsi character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.hayvanID,
        h.ad,
        h.tur,
        h.yas,
        h.cins
    FROM Hayvan h
    INNER JOIN SahipHayvan sh 
        ON h.hayvanID = sh.hayvanID
    WHERE sh.sahipID = p_sahipID;
END;
$$;


ALTER FUNCTION public.fn_kullanicihayvanlari(p_sahipid integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 18624)
-- Name: fn_yasgrububul(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_yasgrububul(p_yas integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_yas IS NULL THEN
        RETURN 'Bilinmiyor';
    ELSIF p_yas < 1 THEN
        RETURN 'Yavru';
    ELSIF p_yas BETWEEN 1 AND 3 THEN
        RETURN 'Genç';
    ELSIF p_yas BETWEEN 4 AND 7 THEN
        RETURN 'Yetişkin';
    ELSE
        RETURN 'Yaşlı';
    END IF;
END;
$$;


ALTER FUNCTION public.fn_yasgrububul(p_yas integer) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 18634)
-- Name: fn_yoneticisilmeengeli(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_yoneticisilmeengeli() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Yönetici rolündeki kullanıcı silinemez
    IF OLD.rolID = 1 THEN
        RAISE EXCEPTION 
        'Güvenlik Hatası: Yönetici rolündeki kullanıcılar sistemden silinemez!';
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.fn_yoneticisilmeengeli() OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 18640)
-- Name: sp_hayvannakilet(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_hayvannakilet(IN p_hayvanid integer, IN p_yenibarinakid integer, IN p_calisanid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE Hayvan 
    SET barinakID = p_yeniBarinakID 
    WHERE hayvanID = p_hayvanID;

    INSERT INTO BakimKaydi (hayvanID, calisanID, islem, tarih, aciklama)
    VALUES (p_hayvanID, p_calisanID, 'Barınak Nakli', CURRENT_DATE, 'Hayvan yeni barınağa nakledildi.');

    RAISE NOTICE 'Hayvan transfer edildi ve işlem bakım kaydı olarak loglandı.';
END;
$$;


ALTER PROCEDURE public.sp_hayvannakilet(IN p_hayvanid integer, IN p_yenibarinakid integer, IN p_calisanid integer) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 18639)
-- Name: sp_muayenevestokdus(integer, integer, integer, integer, text, text); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_muayenevestokdus(IN p_hayvanid integer, IN p_veterinerid integer, IN p_stokid integer, IN p_harcananmiktar integer, IN p_teshis text, IN p_tedavi text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO SaglikKaydi (tarih, teshis, tedavi, hayvanID, veterinerID)
    VALUES (CURRENT_DATE, p_teshis, p_tedavi, p_hayvanID, p_veterinerID);

    UPDATE Stok 
    SET miktar = miktar - p_harcananMiktar 
    WHERE stokID = p_stokID;

    UPDATE Hayvan 
    SET saglikDurumu = p_teshis 
    WHERE hayvanID = p_hayvanID;

    RAISE NOTICE 'Muayene işlendi ve stok güncellendi.';
END;
$$;


ALTER PROCEDURE public.sp_muayenevestokdus(IN p_hayvanid integer, IN p_veterinerid integer, IN p_stokid integer, IN p_harcananmiktar integer, IN p_teshis text, IN p_tedavi text) OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 18638)
-- Name: sp_sahiplendirmetamamla(integer, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_sahiplendirmetamamla(IN p_sahipid integer, IN p_hayvanid integer, IN p_barinakid integer, IN p_basvuruid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE Basvuru SET durum = 'Onaylandı' WHERE basvuruID = p_basvuruID;

    UPDATE Hayvan SET durum = 'Sahiplendirildi' WHERE hayvanID = p_hayvanID;

    INSERT INTO SahiplendirmeBelgesi (tarih, bilgi, basvuruID, sahipID, barinakID, hayvanID)
    VALUES (CURRENT_DATE, 'Sahiplendirme işlemi tamamlandı.', p_basvuruID, p_sahipID, p_barinakID, p_hayvanID);

    INSERT INTO SahipHayvan (sahipID, hayvanID) VALUES (p_sahipID, p_hayvanID);

    RAISE NOTICE 'İşlem başarıyla tamamlandı.';
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Hata oluştu, veriler geri alındı: %', SQLERRM;
END;
$$;


ALTER PROCEDURE public.sp_sahiplendirmetamamla(IN p_sahipid integer, IN p_hayvanid integer, IN p_barinakid integer, IN p_basvuruid integer) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 18632)
-- Name: trg_basvuruonay_belgeolustur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_basvuruonay_belgeolustur() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.durum = 'Onaylandı' AND OLD.durum <> 'Onaylandı' THEN
        INSERT INTO SahiplendirmeBelgesi (tarih, bilgi, basvuruID, sahipID, hayvanID)
        VALUES (
            CURRENT_DATE,
            'Otomatik oluşturulan sahiplendirme belgesi.',
            NEW.basvuruID,
            NEW.sahipID,
            NEW.hayvanID
        );
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_basvuruonay_belgeolustur() OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 18630)
-- Name: trg_hayvanekle_kapasitekontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_hayvanekle_kapasitekontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_kapasite INT;
    v_mevcut INT;
BEGIN
    SELECT kapasite INTO v_kapasite
    FROM Barinak
    WHERE barinakID = NEW.barinakID;

    SELECT COUNT(*) INTO v_mevcut
    FROM Hayvan
    WHERE barinakID = NEW.barinakID;

    IF v_mevcut >= v_kapasite THEN
        RAISE EXCEPTION 'Barınak kapasitesi dolu. Hayvan eklenemez.';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_hayvanekle_kapasitekontrol() OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 18636)
-- Name: trg_hayvansil_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_hayvansil_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM SahiplendirmeBelgesi
        WHERE hayvanID = OLD.hayvanID
    ) THEN
        RAISE EXCEPTION 'Sahiplendirilmiş hayvan silinemez.';
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.trg_hayvansil_kontrol() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 237 (class 1259 OID 18225)
-- Name: bakimkaydi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bakimkaydi (
    bakimid integer NOT NULL,
    hayvanid integer,
    gonulluid integer,
    calisanid integer,
    islem text,
    tarih date,
    aciklama text
);


ALTER TABLE public.bakimkaydi OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 18224)
-- Name: bakimkaydi_bakimid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bakimkaydi_bakimid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bakimkaydi_bakimid_seq OWNER TO postgres;

--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 236
-- Name: bakimkaydi_bakimid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bakimkaydi_bakimid_seq OWNED BY public.bakimkaydi.bakimid;


--
-- TOC entry 227 (class 1259 OID 18137)
-- Name: barinak; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.barinak (
    barinakid integer NOT NULL,
    ad character varying(100),
    adres character varying(200),
    telefon character varying(20),
    eposta character varying(100),
    kapasite integer,
    yoneticiid integer
);


ALTER TABLE public.barinak OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 18136)
-- Name: barinak_barinakid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.barinak_barinakid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.barinak_barinakid_seq OWNER TO postgres;

--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 226
-- Name: barinak_barinakid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.barinak_barinakid_seq OWNED BY public.barinak.barinakid;


--
-- TOC entry 231 (class 1259 OID 18163)
-- Name: basvuru; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.basvuru (
    basvuruid integer NOT NULL,
    tarih date,
    durum character varying(50),
    notlar text,
    sahipid integer,
    hayvanid integer
);


ALTER TABLE public.basvuru OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 18162)
-- Name: basvuru_basvuruid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.basvuru_basvuruid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.basvuru_basvuruid_seq OWNER TO postgres;

--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 230
-- Name: basvuru_basvuruid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.basvuru_basvuruid_seq OWNED BY public.basvuru.basvuruid;


--
-- TOC entry 223 (class 1259 OID 18106)
-- Name: calisan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calisan (
    calisanid integer NOT NULL,
    gorev character varying(100),
    baslamatarihi date
);


ALTER TABLE public.calisan OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 18278)
-- Name: calisanhayvan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calisanhayvan (
    calisanid integer NOT NULL,
    hayvanid integer NOT NULL
);


ALTER TABLE public.calisanhayvan OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 18116)
-- Name: gonullu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gonullu (
    gonulluid integer NOT NULL,
    gorevturu character varying(100),
    kayittarihi date
);


ALTER TABLE public.gonullu OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 18263)
-- Name: gonulluhayvan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gonulluhayvan (
    gonulluid integer NOT NULL,
    hayvanid integer NOT NULL
);


ALTER TABLE public.gonulluhayvan OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 18149)
-- Name: hayvan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hayvan (
    hayvanid bigint NOT NULL,
    ad character varying(255),
    tur character varying(255),
    yas integer,
    cinsiyet character varying(255),
    cins character varying(255),
    giristarihi date,
    saglikdurumu character varying(255),
    fotograf character varying(255),
    durum character varying(255),
    barinakid bigint
);


ALTER TABLE public.hayvan OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 18148)
-- Name: hayvan_hayvanid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hayvan_hayvanid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hayvan_hayvanid_seq OWNER TO postgres;

--
-- TOC entry 5095 (class 0 OID 0)
-- Dependencies: 228
-- Name: hayvan_hayvanid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hayvan_hayvanid_seq OWNED BY public.hayvan.hayvanid;


--
-- TOC entry 220 (class 1259 OID 18075)
-- Name: kullanici; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kullanici (
    kullaniciid integer NOT NULL,
    adsoyad character varying(100),
    email character varying(100),
    sifre character varying(100),
    rolid integer
);


ALTER TABLE public.kullanici OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 18074)
-- Name: kullanici_kullaniciid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kullanici_kullaniciid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kullanici_kullaniciid_seq OWNER TO postgres;

--
-- TOC entry 5096 (class 0 OID 0)
-- Dependencies: 219
-- Name: kullanici_kullaniciid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kullanici_kullaniciid_seq OWNED BY public.kullanici.kullaniciid;


--
-- TOC entry 218 (class 1259 OID 18066)
-- Name: rol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rol (
    rolid integer NOT NULL,
    roladi character varying(50)
);


ALTER TABLE public.rol OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 18065)
-- Name: rol_rolid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rol_rolid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rol_rolid_seq OWNER TO postgres;

--
-- TOC entry 5097 (class 0 OID 0)
-- Dependencies: 217
-- Name: rol_rolid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rol_rolid_seq OWNED BY public.rol.rolid;


--
-- TOC entry 233 (class 1259 OID 18182)
-- Name: sahiplendirmebelgesi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sahiplendirmebelgesi (
    belgeid integer NOT NULL,
    tarih date,
    bilgi text,
    basvuruid integer,
    sahipid integer,
    hayvanid integer,
    barinakid integer
);


ALTER TABLE public.sahiplendirmebelgesi OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 18181)
-- Name: s_belgesi_belgeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.s_belgesi_belgeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.s_belgesi_belgeid_seq OWNER TO postgres;

--
-- TOC entry 5098 (class 0 OID 0)
-- Dependencies: 232
-- Name: s_belgesi_belgeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.s_belgesi_belgeid_seq OWNED BY public.sahiplendirmebelgesi.belgeid;


--
-- TOC entry 235 (class 1259 OID 18206)
-- Name: saglikkaydi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saglikkaydi (
    saglikid integer NOT NULL,
    tarih date,
    teshis text,
    tedavi text,
    ilaclar text,
    notlar text,
    hayvanid integer,
    veterinerid integer
);


ALTER TABLE public.saglikkaydi OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 18205)
-- Name: saglikkaydi_saglikid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saglikkaydi_saglikid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.saglikkaydi_saglikid_seq OWNER TO postgres;

--
-- TOC entry 5099 (class 0 OID 0)
-- Dependencies: 234
-- Name: saglikkaydi_saglikid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.saglikkaydi_saglikid_seq OWNED BY public.saglikkaydi.saglikid;


--
-- TOC entry 222 (class 1259 OID 18096)
-- Name: sahip; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sahip (
    sahipid integer NOT NULL,
    kimlikno character varying(11),
    iletisim character varying(100)
);


ALTER TABLE public.sahip OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 18248)
-- Name: sahiphayvan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sahiphayvan (
    sahipid integer NOT NULL,
    hayvanid integer NOT NULL
);


ALTER TABLE public.sahiphayvan OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 18309)
-- Name: stok; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stok (
    stokid integer NOT NULL,
    ad character varying(100),
    kategori character varying(50),
    miktar integer,
    birim character varying(20),
    barinakid integer
);


ALTER TABLE public.stok OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 18308)
-- Name: stok_stokid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stok_stokid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stok_stokid_seq OWNER TO postgres;

--
-- TOC entry 5100 (class 0 OID 0)
-- Dependencies: 242
-- Name: stok_stokid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stok_stokid_seq OWNED BY public.stok.stokid;


--
-- TOC entry 225 (class 1259 OID 18126)
-- Name: veteriner; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veteriner (
    veterinerid integer NOT NULL,
    uzmanlik character varying(100),
    calismasaatleri character varying(100)
);


ALTER TABLE public.veteriner OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 18086)
-- Name: yonetici; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yonetici (
    yoneticiid integer NOT NULL,
    yetkiseviyesi character varying(50)
);


ALTER TABLE public.yonetici OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 18293)
-- Name: yoneticibasvuru; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yoneticibasvuru (
    yoneticiid integer NOT NULL,
    basvuruid integer NOT NULL,
    onaydurumu character varying(50)
);


ALTER TABLE public.yoneticibasvuru OWNER TO postgres;

--
-- TOC entry 4838 (class 2604 OID 18228)
-- Name: bakimkaydi bakimid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bakimkaydi ALTER COLUMN bakimid SET DEFAULT nextval('public.bakimkaydi_bakimid_seq'::regclass);


--
-- TOC entry 4833 (class 2604 OID 18140)
-- Name: barinak barinakid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.barinak ALTER COLUMN barinakid SET DEFAULT nextval('public.barinak_barinakid_seq'::regclass);


--
-- TOC entry 4835 (class 2604 OID 18166)
-- Name: basvuru basvuruid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basvuru ALTER COLUMN basvuruid SET DEFAULT nextval('public.basvuru_basvuruid_seq'::regclass);


--
-- TOC entry 4834 (class 2604 OID 18645)
-- Name: hayvan hayvanid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hayvan ALTER COLUMN hayvanid SET DEFAULT nextval('public.hayvan_hayvanid_seq'::regclass);


--
-- TOC entry 4832 (class 2604 OID 18078)
-- Name: kullanici kullaniciid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici ALTER COLUMN kullaniciid SET DEFAULT nextval('public.kullanici_kullaniciid_seq'::regclass);


--
-- TOC entry 4831 (class 2604 OID 18069)
-- Name: rol rolid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol ALTER COLUMN rolid SET DEFAULT nextval('public.rol_rolid_seq'::regclass);


--
-- TOC entry 4837 (class 2604 OID 18209)
-- Name: saglikkaydi saglikid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saglikkaydi ALTER COLUMN saglikid SET DEFAULT nextval('public.saglikkaydi_saglikid_seq'::regclass);


--
-- TOC entry 4836 (class 2604 OID 18185)
-- Name: sahiplendirmebelgesi belgeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahiplendirmebelgesi ALTER COLUMN belgeid SET DEFAULT nextval('public.s_belgesi_belgeid_seq'::regclass);


--
-- TOC entry 4839 (class 2604 OID 18312)
-- Name: stok stokid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stok ALTER COLUMN stokid SET DEFAULT nextval('public.stok_stokid_seq'::regclass);


--
-- TOC entry 5078 (class 0 OID 18225)
-- Dependencies: 237
-- Data for Name: bakimkaydi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bakimkaydi (bakimid, hayvanid, gonulluid, calisanid, islem, tarih, aciklama) FROM stdin;
1	12	14	9	Egzersiz	2024-03-28	Max ile bahçede 1 saat top oynandı.
2	6	15	10	Besleme ve Temizlik	2024-03-28	Tekir’in maması verildi, kumu temizlendi.
3	21	16	10	Akvaryum Bakımı	2024-03-28	Suyun pH dengesi kontrol edildi.
4	1	17	12	Kafes Temizliği	2024-03-28	Maviş’in kafesi dezenfekte edildi.
\.


--
-- TOC entry 5068 (class 0 OID 18137)
-- Dependencies: 227
-- Data for Name: barinak; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.barinak (barinakid, ad, adres, telefon, eposta, kapasite, yoneticiid) FROM stdin;
1	Müşterek Hayat İstasyonu	Malatya/Battalgazi	0216111	bilgi@musterekhayatistasyonu.com	50	1
\.


--
-- TOC entry 5072 (class 0 OID 18163)
-- Dependencies: 231
-- Data for Name: basvuru; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.basvuru (basvuruid, tarih, durum, notlar, sahipid, hayvanid) FROM stdin;
1	2024-03-20	Onaylandı	Bahçeli evim var, Max ile iyi anlaşacağımızı düşünüyorum.	4	12
3	2024-03-25	Reddedildi	Apartman dairesinde Kangal bakmak uygun değil.	6	11
4	2024-03-26	Onaylandı	Çocuklarım için uysal bir tavşan arıyoruz.	7	19
5	2024-03-27	Beklemede	Ofisime akvaryum kurdum, Goldie için talibim.	8	34
2	2024-03-22	Onaylandı	Daha önce kedi baktım, Tekir için başvuruyorum.	5	6
\.


--
-- TOC entry 5064 (class 0 OID 18106)
-- Dependencies: 223
-- Data for Name: calisan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calisan (calisanid, gorev, baslamatarihi) FROM stdin;
9	Bakıcı	2023-01-10
10	Temizlik	2023-02-15
11	Güvenlik	2023-03-20
12	Bakıcı	2023-04-25
13	Şoför	2023-05-30
\.


--
-- TOC entry 5081 (class 0 OID 18278)
-- Dependencies: 240
-- Data for Name: calisanhayvan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calisanhayvan (calisanid, hayvanid) FROM stdin;
9	11
9	12
9	13
10	6
10	7
10	8
12	1
12	2
12	3
\.


--
-- TOC entry 5065 (class 0 OID 18116)
-- Dependencies: 224
-- Data for Name: gonullu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gonullu (gonulluid, gorevturu, kayittarihi) FROM stdin;
14	Oyun Saati	2024-01-01
15	Besleme	2024-01-05
16	Temizlik	2024-01-10
17	Sosyal Medya	2024-01-15
18	Etkinlik	2024-01-20
\.


--
-- TOC entry 5080 (class 0 OID 18263)
-- Dependencies: 239
-- Data for Name: gonulluhayvan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gonulluhayvan (gonulluid, hayvanid) FROM stdin;
14	12
15	6
16	21
17	1
\.


--
-- TOC entry 5070 (class 0 OID 18149)
-- Dependencies: 229
-- Data for Name: hayvan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hayvan (hayvanid, ad, tur, yas, cinsiyet, cins, giristarihi, saglikdurumu, fotograf, durum, barinakid) FROM stdin;
6	Tekir	Kedi	2	Erkek	Tekir	2023-09-20	Sağlıklı	fotograflar/hayvan6.jpg	Sahiplendirilebilir	1
8	Mia	Kedi	1	Dişi	Van Kedisi	2023-12-01	Sağlıklı	fotograflar/hayvan8.jpg	Sahiplendirilebilir	1
11	Karabaş	Köpek	4	Erkek	Kangal	2023-08-10	Sağlıklı	fotograflar/hayvan11.jpg	Beklemede	1
12	Max	Köpek	2	Erkek	Golden Retriever	2023-11-20	İyi	fotograflar/hayvan12.jpg	Sahiplendirilebilir	1
13	Zeytin	Köpek	3	Dişi	Cocker	2023-12-15	Sağlıklı	fotograflar/hayvan13.jpg	Sahiplendirilebilir	1
15	Tarçın	Köpek	1	Dişi	Poodle	2024-03-01	Sağlıklı	fotograflar/hayvan15.jpg	Sahiplendirilebilir	1
17	Pamuk	Tavşan	2	Dişi	Angora	2023-12-10	Sağlıklı	fotograflar/hayvan17.jpg	Beklemede	1
19	Kartopu	Tavşan	1	Dişi	Cüce Tavşan	2024-02-05	Sağlıklı	fotograflar/hayvan19.jpg	Sahiplendirilebilir	1
20	Gofret	Tavşan	2	Erkek	Rex Tavşanı	2024-02-25	Sağlıklı	fotograflar/hayvan20.jpg	Beklemede	1
21	Tosbik	Kaplumbağa	10	Erkek	Su Kaplumbağası	2023-05-20	Sağlıklı	fotograflar/hayvan21.jpg	Beklemede	1
22	Kabuk	Kaplumbağa	5	Dişi	Kara Kaplumbağası	2023-07-15	İyi	fotograflar/hayvan22.jpg	Beklemede	1
23	Hızlı	Kaplumbağa	12	Erkek	Su Kaplumbağası	2023-09-30	Sağlıklı	fotograflar/hayvan23.jpg	Beklemede	1
24	Ninja	Kaplumbağa	8	Erkek	Kırmızı Yanaklı	2023-11-12	Sağlıklı	fotograflar/hayvan24.jpg	Sahiplendirilebilir	1
25	Yeşil	Kaplumbağa	15	Dişi	Kara Kaplumbağası	2024-01-10	Sağlıklı	fotograflar/hayvan25.jpg	Beklemede	1
26	Pırtık	Hamster	1	Erkek	Suriye Hamsterı	2023-12-15	Sağlıklı	fotograflar/hayvan26.jpg	Beklemede	1
27	Boncuk	Hamster	1	Dişi	Goncubaş	2024-01-20	İyi	fotograflar/hayvan27.jpg	Sahiplendirilebilir	1
30	Çekirdek	Hamster	1	Dişi	Rus Hamsterı	2024-03-05	Sağlıklı	fotograflar/hayvan30.jpg	Beklemede	1
31	Nemo	Balık	1	Erkek	Palyaço Balığı	2024-03-10	Sağlıklı	fotograflar/hayvan31.jpg	Sahiplendirilebilir	1
34	Goldie	Balık	1	Dişi	Japon Balığı	2024-03-18	Sağlıklı	fotograflar/hayvan34.jpg	Sahiplendirilebilir	1
2	Çapkın	Kuş	2	Erkek	Kanarya	2023-11-15	İyi	fotograflar/hayvan2.jpg	Sahiplendirildi	1
1	Maviş	Kuş	1	Erkek	Muhabbet Kuşu	2023-10-01	Sağlıklı	fotograflar/hayvan1.jpg	Sahiplendirildi	1
3	Bulut	Kuş	1	Dişi	Sultan Papağanı	2023-12-05	Sağlıklı	fotograflar/hayvan3.jpg	Sahiplendirildi	1
5	Güneş	Kuş	1	Erkek	Hint Bülbülü	2024-02-20	Sağlıklı	fotograflar/hayvan5.jpg	Sahiplendirildi	1
28	Fındık	Hamster	2	Erkek	Roborovski	2024-02-10	Sağlıklı	fotograflar/hayvan28.jpg	Sahiplendirildi	1
38	Karabaş	Köpek	4	Erkek	Kangal	2026-04-18	İyi	\N	Barınakta	1
40	Max	Köpek	3	Erkek	Golden	2026-04-18	İyi	\N	Barınakta	1
7	Duman	Kedi	3	Dişi	Ankara Kedisi	2023-10-15	İyi	fotograflar/hayvan7.jpg	Sahiplendirildi	1
14	Kont	Köpek	5	Erkek	Alman Kurdu	2024-01-20	Hafif Sakat	fotograflar/hayvan14.jpg	Sahiplendirildi	1
29	Kömür	Hamster	1	Erkek	Suriye Hamsterı	2024-02-28	Halsiz	fotograflar/hayvan29.jpg	Sahiplendirildi	1
33	Bubbles	Balık	1	Erkek	Japon Balığı	2024-03-15	Sağlıklı	fotograflar/hayvan33.jpg	Sahiplendirildi	1
\.


--
-- TOC entry 5061 (class 0 OID 18075)
-- Dependencies: 220
-- Data for Name: kullanici; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kullanici (kullaniciid, adsoyad, email, sifre, rolid) FROM stdin;
1	Ahmet Yılmaz	ahmet@sistem.com	12345	1
2	Ayşe Demir	ayse@sistem.com	12345	1
3	Mehmet Can	mehmet@sistem.com	12345	1
4	Selin Su	selin@mail.com	pass1	2
5	Mert Ege	mert@mail.com	pass2	2
6	Ali Veli	ali@mail.com	pass3	2
7	Fatma Nur	fatma@mail.com	pass4	2
8	Caner Şen	caner@mail.com	pass5	2
9	Hüseyin Ak	huseyin@is.com	is123	3
10	Zeynep Al	zeynep@is.com	is123	3
11	Emre Mor	emre@is.com	is123	3
12	Derya Deniz	derya@is.com	is123	3
13	Murat Tek	murat@is.com	is123	3
14	Buse Naz	buse@gonullu.com	g1	4
15	Arda Turan	arda@gonullu.com	g2	4
16	Gizem Kar	gizem@gonullu.com	g3	4
17	Kaan Say	kaan@gonullu.com	g4	4
18	Ece Tan	ece@gonullu.com	g5	4
19	Dr. Selim	selim@vet.com	v1	5
20	Dr. Oya	oya@vet.com	v2	5
21	Dr. Berk	berk@vet.com	v3	5
22	Dr. Nil	nil@vet.com	v4	5
23	Dr. Sarp	sarp@vet.com	v5	5
\.


--
-- TOC entry 5059 (class 0 OID 18066)
-- Dependencies: 218
-- Data for Name: rol; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rol (rolid, roladi) FROM stdin;
1	Yonetici
2	Sahip
3	Calisan
4	Gonullu
5	Veteriner
\.


--
-- TOC entry 5076 (class 0 OID 18206)
-- Dependencies: 235
-- Data for Name: saglikkaydi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.saglikkaydi (saglikid, tarih, teshis, tedavi, ilaclar, notlar, hayvanid, veterinerid) FROM stdin;
1	2024-03-05	Genel Kontrol	Parazit uygulaması yapıldı.	İç-Dış Parazit Damlası	Gayet sağlıklı.	6	22
3	2024-03-15	İştahsızlık	Vitamin takviyesi verildi.	Multivitamin	Beslenme düzeni değiştirildi.	30	20
4	2024-03-18	Aşı Takvimi	Kuduz aşısı uygulandı.	Kuduz Aşısı	Yıllık rutin aşı.	11	23
\.


--
-- TOC entry 5063 (class 0 OID 18096)
-- Dependencies: 222
-- Data for Name: sahip; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sahip (sahipid, kimlikno, iletisim) FROM stdin;
4	11111111110	555-001
5	11111111111	555-002
6	11111111112	555-003
7	11111111113	555-004
8	11111111114	555-005
\.


--
-- TOC entry 5079 (class 0 OID 18248)
-- Dependencies: 238
-- Data for Name: sahiphayvan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sahiphayvan (sahipid, hayvanid) FROM stdin;
4	12
7	19
5	2
5	1
5	3
5	5
5	28
5	7
5	14
5	29
5	33
\.


--
-- TOC entry 5074 (class 0 OID 18182)
-- Dependencies: 233
-- Data for Name: sahiplendirmebelgesi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sahiplendirmebelgesi (belgeid, tarih, bilgi, basvuruid, sahipid, hayvanid, barinakid) FROM stdin;
1	2024-03-21	Max isimli köpek Selin Su adına tescil edilmiştir.	1	4	12	\N
2	2024-03-28	Kartopu isimli tavşan Fatma Nur adına tescil edilmiştir.	4	7	19	\N
3	2025-12-31	Sahiplendirme işlemi tamamlandı.	1	4	1	1
5	2025-12-31	Sahiplendirme işlemi tamamlandı.	1	4	1	1
6	2025-12-31	Sahiplendirme işlemi tamamlandı.	1	4	1	1
8	2025-12-31	Sahiplendirme işlemi tamamlandı.	1	4	1	1
10	2026-04-17	Otomatik oluşturulan sahiplendirme belgesi.	2	5	6	\N
11	2026-04-17	Sahiplendirme işlemi tamamlandı.	2	5	2	1
13	2026-04-18	Sahiplendirme işlemi tamamlandı.	2	5	1	1
14	2026-04-18	Sahiplendirme işlemi tamamlandı.	2	5	3	1
16	2026-04-18	Sahiplendirme işlemi tamamlandı.	2	5	5	1
18	2026-04-18	Sahiplendirme işlemi tamamlandı.	2	5	28	1
21	2026-04-18	Sahiplendirme işlemi tamamlandı.	2	5	7	1
22	2026-04-18	Sahiplendirme işlemi tamamlandı.	2	5	14	1
23	2026-04-18	Sahiplendirme işlemi tamamlandı.	2	5	29	1
24	2026-04-18	Sahiplendirme işlemi tamamlandı.	2	5	33	1
\.


--
-- TOC entry 5084 (class 0 OID 18309)
-- Dependencies: 243
-- Data for Name: stok; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stok (stokid, ad, kategori, miktar, birim, barinakid) FROM stdin;
1	Premium Kedi Maması	Mama	150	kg	1
2	Yetişkin Köpek Maması	Mama	300	kg	1
3	Karışık Kuş Yemi	Mama	20	kg	1
4	Tavşan Pelleti (Yoncalı)	Mama	30	kg	1
5	Kaplumbağa Stick Yem	Mama	10	kg	1
6	Hamster Karışık Tahıl	Mama	15	kg	1
7	Balık Pul Yemi	Mama	5	kg	1
8	Kedi Kumu	Temizlik	100	Litre	1
9	Kemirgen Taban Talaşı	Temizlik	50	kg	1
10	Akvaryum Su Düzenleyici	Sağlık	10	Adet	1
11	Genel Parazit Damlası	Sağlık	40	Adet	1
12	Multivitamin Takviyesi	Sağlık	25	Adet	1
13	Taşıma Çantası	Ekipman	15	Adet	1
14	Su Kabı (Paslanmaz)	Ekipman	30	Adet	1
15	Kuduz Aşısı	Sağlık	50	Doz	1
16	Karma Aşı (Kedi/Köpek)	Sağlık	100	Doz	1
17	Antibiyotik Şurup	Sağlık	20	Şişe	1
18	Antiseptik Solüsyon (Batikon)	Sağlık	15	Litre	1
19	Steril Gazlı Bez	Sağlık	200	Paket	1
20	Cerrahi Maske ve Eldiven Seti	Sağlık	500	Adet	1
21	Enjektör (2ml/5ml)	Sağlık	300	Adet	1
22	Yara Bandajı (Esnek)	Sağlık	40	Rulo	1
23	Mikroçip Kiti	Sağlık	60	Adet	1
24	Ateş Ölçer (Dijital)	Sağlık	10	Adet	1
25	Parazit Önleyici Hap	Sağlık	120	Tablet	1
26	Göz ve Kulak Temizleme Damlası	Sağlık	30	Şişe	1
\.


--
-- TOC entry 5066 (class 0 OID 18126)
-- Dependencies: 225
-- Data for Name: veteriner; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veteriner (veterinerid, uzmanlik, calismasaatleri) FROM stdin;
19	Cerrahi	08:00-17:00
20	Dahiliye	09:00-18:00
21	Kardiyoloji	10:00-19:00
22	Genel	08:00-17:00
23	Aşı	09:00-18:00
\.


--
-- TOC entry 5062 (class 0 OID 18086)
-- Dependencies: 221
-- Data for Name: yonetici; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.yonetici (yoneticiid, yetkiseviyesi) FROM stdin;
1	Yüksek
2	Orta
3	Alt
\.


--
-- TOC entry 5082 (class 0 OID 18293)
-- Dependencies: 241
-- Data for Name: yoneticibasvuru; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.yoneticibasvuru (yoneticiid, basvuruid, onaydurumu) FROM stdin;
1	1	Onaylandı
2	2	İncelemede
1	3	Reddedildi
3	4	Onaylandı
2	5	İncelemede
\.


--
-- TOC entry 5101 (class 0 OID 0)
-- Dependencies: 236
-- Name: bakimkaydi_bakimid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bakimkaydi_bakimid_seq', 4, true);


--
-- TOC entry 5102 (class 0 OID 0)
-- Dependencies: 226
-- Name: barinak_barinakid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.barinak_barinakid_seq', 1, true);


--
-- TOC entry 5103 (class 0 OID 0)
-- Dependencies: 230
-- Name: basvuru_basvuruid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.basvuru_basvuruid_seq', 5, true);


--
-- TOC entry 5104 (class 0 OID 0)
-- Dependencies: 228
-- Name: hayvan_hayvanid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hayvan_hayvanid_seq', 41, true);


--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 219
-- Name: kullanici_kullaniciid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kullanici_kullaniciid_seq', 23, true);


--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 217
-- Name: rol_rolid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rol_rolid_seq', 5, true);


--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 232
-- Name: s_belgesi_belgeid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.s_belgesi_belgeid_seq', 24, true);


--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 234
-- Name: saglikkaydi_saglikid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.saglikkaydi_saglikid_seq', 4, true);


--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 242
-- Name: stok_stokid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stok_stokid_seq', 26, true);


--
-- TOC entry 4870 (class 2606 OID 18232)
-- Name: bakimkaydi bakimkaydi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bakimkaydi
    ADD CONSTRAINT bakimkaydi_pkey PRIMARY KEY (bakimid);


--
-- TOC entry 4858 (class 2606 OID 18142)
-- Name: barinak barinak_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.barinak
    ADD CONSTRAINT barinak_pkey PRIMARY KEY (barinakid);


--
-- TOC entry 4863 (class 2606 OID 18170)
-- Name: basvuru basvuru_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basvuru
    ADD CONSTRAINT basvuru_pkey PRIMARY KEY (basvuruid);


--
-- TOC entry 4852 (class 2606 OID 18110)
-- Name: calisan calisan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisan
    ADD CONSTRAINT calisan_pkey PRIMARY KEY (calisanid);


--
-- TOC entry 4876 (class 2606 OID 18282)
-- Name: calisanhayvan calisanhayvan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisanhayvan
    ADD CONSTRAINT calisanhayvan_pkey PRIMARY KEY (calisanid, hayvanid);


--
-- TOC entry 4854 (class 2606 OID 18120)
-- Name: gonullu gonullu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gonullu
    ADD CONSTRAINT gonullu_pkey PRIMARY KEY (gonulluid);


--
-- TOC entry 4874 (class 2606 OID 18267)
-- Name: gonulluhayvan gonulluhayvan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gonulluhayvan
    ADD CONSTRAINT gonulluhayvan_pkey PRIMARY KEY (gonulluid, hayvanid);


--
-- TOC entry 4860 (class 2606 OID 18647)
-- Name: hayvan hayvan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hayvan
    ADD CONSTRAINT hayvan_pkey PRIMARY KEY (hayvanid);


--
-- TOC entry 4846 (class 2606 OID 18080)
-- Name: kullanici kullanici_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici
    ADD CONSTRAINT kullanici_pkey PRIMARY KEY (kullaniciid);


--
-- TOC entry 4841 (class 2606 OID 18071)
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (rolid);


--
-- TOC entry 4843 (class 2606 OID 18073)
-- Name: rol rol_roladi_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_roladi_key UNIQUE (roladi);


--
-- TOC entry 4866 (class 2606 OID 18189)
-- Name: sahiplendirmebelgesi s_belgesi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahiplendirmebelgesi
    ADD CONSTRAINT s_belgesi_pkey PRIMARY KEY (belgeid);


--
-- TOC entry 4868 (class 2606 OID 18213)
-- Name: saglikkaydi saglikkaydi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saglikkaydi
    ADD CONSTRAINT saglikkaydi_pkey PRIMARY KEY (saglikid);


--
-- TOC entry 4850 (class 2606 OID 18100)
-- Name: sahip sahip_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahip
    ADD CONSTRAINT sahip_pkey PRIMARY KEY (sahipid);


--
-- TOC entry 4872 (class 2606 OID 18252)
-- Name: sahiphayvan sahiphayvan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahiphayvan
    ADD CONSTRAINT sahiphayvan_pkey PRIMARY KEY (sahipid, hayvanid);


--
-- TOC entry 4880 (class 2606 OID 18314)
-- Name: stok stok_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stok
    ADD CONSTRAINT stok_pkey PRIMARY KEY (stokid);


--
-- TOC entry 4856 (class 2606 OID 18130)
-- Name: veteriner veteriner_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veteriner
    ADD CONSTRAINT veteriner_pkey PRIMARY KEY (veterinerid);


--
-- TOC entry 4848 (class 2606 OID 18090)
-- Name: yonetici yonetici_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yonetici
    ADD CONSTRAINT yonetici_pkey PRIMARY KEY (yoneticiid);


--
-- TOC entry 4878 (class 2606 OID 18297)
-- Name: yoneticibasvuru yoneticibasvuru_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yoneticibasvuru
    ADD CONSTRAINT yoneticibasvuru_pkey PRIMARY KEY (yoneticiid, basvuruid);


--
-- TOC entry 4864 (class 1259 OID 18643)
-- Name: idx_basvuru_sahip_hayvan; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_basvuru_sahip_hayvan ON public.basvuru USING btree (sahipid, hayvanid);


--
-- TOC entry 4861 (class 1259 OID 18703)
-- Name: idx_hayvan_barinak_durum; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hayvan_barinak_durum ON public.hayvan USING btree (barinakid, durum);


--
-- TOC entry 4844 (class 1259 OID 18641)
-- Name: idx_kullanici_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_kullanici_email ON public.kullanici USING btree (email);


--
-- TOC entry 4912 (class 2620 OID 18633)
-- Name: basvuru trg_after_basvuru_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_after_basvuru_update AFTER UPDATE ON public.basvuru FOR EACH ROW EXECUTE FUNCTION public.trg_basvuruonay_belgeolustur();


--
-- TOC entry 4910 (class 2620 OID 18637)
-- Name: hayvan trg_before_hayvan_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_before_hayvan_delete BEFORE DELETE ON public.hayvan FOR EACH ROW EXECUTE FUNCTION public.trg_hayvansil_kontrol();


--
-- TOC entry 4911 (class 2620 OID 18631)
-- Name: hayvan trg_before_hayvan_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_before_hayvan_insert BEFORE INSERT ON public.hayvan FOR EACH ROW EXECUTE FUNCTION public.trg_hayvanekle_kapasitekontrol();


--
-- TOC entry 4909 (class 2620 OID 18635)
-- Name: kullanici trg_yoneticisilmeengeli; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_yoneticisilmeengeli BEFORE DELETE ON public.kullanici FOR EACH ROW EXECUTE FUNCTION public.fn_yoneticisilmeengeli();


--
-- TOC entry 4897 (class 2606 OID 18243)
-- Name: bakimkaydi bakimkaydi_calisanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bakimkaydi
    ADD CONSTRAINT bakimkaydi_calisanid_fkey FOREIGN KEY (calisanid) REFERENCES public.calisan(calisanid);


--
-- TOC entry 4898 (class 2606 OID 18238)
-- Name: bakimkaydi bakimkaydi_gonulluid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bakimkaydi
    ADD CONSTRAINT bakimkaydi_gonulluid_fkey FOREIGN KEY (gonulluid) REFERENCES public.gonullu(gonulluid);


--
-- TOC entry 4899 (class 2606 OID 18786)
-- Name: bakimkaydi bakimkaydi_hayvanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bakimkaydi
    ADD CONSTRAINT bakimkaydi_hayvanid_fkey FOREIGN KEY (hayvanid) REFERENCES public.hayvan(hayvanid) ON DELETE CASCADE;


--
-- TOC entry 4887 (class 2606 OID 18143)
-- Name: barinak barinak_yoneticiid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.barinak
    ADD CONSTRAINT barinak_yoneticiid_fkey FOREIGN KEY (yoneticiid) REFERENCES public.yonetici(yoneticiid);


--
-- TOC entry 4889 (class 2606 OID 18796)
-- Name: basvuru basvuru_hayvanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basvuru
    ADD CONSTRAINT basvuru_hayvanid_fkey FOREIGN KEY (hayvanid) REFERENCES public.hayvan(hayvanid) ON DELETE CASCADE;


--
-- TOC entry 4890 (class 2606 OID 18171)
-- Name: basvuru basvuru_sahipid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basvuru
    ADD CONSTRAINT basvuru_sahipid_fkey FOREIGN KEY (sahipid) REFERENCES public.sahip(sahipid);


--
-- TOC entry 4884 (class 2606 OID 18111)
-- Name: calisan calisan_calisanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisan
    ADD CONSTRAINT calisan_calisanid_fkey FOREIGN KEY (calisanid) REFERENCES public.kullanici(kullaniciid);


--
-- TOC entry 4904 (class 2606 OID 18283)
-- Name: calisanhayvan calisanhayvan_calisanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisanhayvan
    ADD CONSTRAINT calisanhayvan_calisanid_fkey FOREIGN KEY (calisanid) REFERENCES public.calisan(calisanid);


--
-- TOC entry 4905 (class 2606 OID 18816)
-- Name: calisanhayvan calisanhayvan_hayvanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisanhayvan
    ADD CONSTRAINT calisanhayvan_hayvanid_fkey FOREIGN KEY (hayvanid) REFERENCES public.hayvan(hayvanid) ON DELETE CASCADE;


--
-- TOC entry 4885 (class 2606 OID 18121)
-- Name: gonullu gonullu_gonulluid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gonullu
    ADD CONSTRAINT gonullu_gonulluid_fkey FOREIGN KEY (gonulluid) REFERENCES public.kullanici(kullaniciid);


--
-- TOC entry 4902 (class 2606 OID 18268)
-- Name: gonulluhayvan gonulluhayvan_gonulluid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gonulluhayvan
    ADD CONSTRAINT gonulluhayvan_gonulluid_fkey FOREIGN KEY (gonulluid) REFERENCES public.gonullu(gonulluid);


--
-- TOC entry 4903 (class 2606 OID 18811)
-- Name: gonulluhayvan gonulluhayvan_hayvanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gonulluhayvan
    ADD CONSTRAINT gonulluhayvan_hayvanid_fkey FOREIGN KEY (hayvanid) REFERENCES public.hayvan(hayvanid) ON DELETE CASCADE;


--
-- TOC entry 4888 (class 2606 OID 18691)
-- Name: hayvan hayvan_barinakid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hayvan
    ADD CONSTRAINT hayvan_barinakid_fkey FOREIGN KEY (barinakid) REFERENCES public.barinak(barinakid);


--
-- TOC entry 4881 (class 2606 OID 18081)
-- Name: kullanici kullanici_rolid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici
    ADD CONSTRAINT kullanici_rolid_fkey FOREIGN KEY (rolid) REFERENCES public.rol(rolid);


--
-- TOC entry 4891 (class 2606 OID 18190)
-- Name: sahiplendirmebelgesi s_belgesi_basvuruid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahiplendirmebelgesi
    ADD CONSTRAINT s_belgesi_basvuruid_fkey FOREIGN KEY (basvuruid) REFERENCES public.basvuru(basvuruid);


--
-- TOC entry 4892 (class 2606 OID 18806)
-- Name: sahiplendirmebelgesi s_belgesi_hayvanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahiplendirmebelgesi
    ADD CONSTRAINT s_belgesi_hayvanid_fkey FOREIGN KEY (hayvanid) REFERENCES public.hayvan(hayvanid) ON DELETE CASCADE;


--
-- TOC entry 4893 (class 2606 OID 18195)
-- Name: sahiplendirmebelgesi s_belgesi_sahipid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahiplendirmebelgesi
    ADD CONSTRAINT s_belgesi_sahipid_fkey FOREIGN KEY (sahipid) REFERENCES public.sahip(sahipid);


--
-- TOC entry 4895 (class 2606 OID 18791)
-- Name: saglikkaydi saglikkaydi_hayvanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saglikkaydi
    ADD CONSTRAINT saglikkaydi_hayvanid_fkey FOREIGN KEY (hayvanid) REFERENCES public.hayvan(hayvanid) ON DELETE CASCADE;


--
-- TOC entry 4896 (class 2606 OID 18219)
-- Name: saglikkaydi saglikkaydi_veterinerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saglikkaydi
    ADD CONSTRAINT saglikkaydi_veterinerid_fkey FOREIGN KEY (veterinerid) REFERENCES public.veteriner(veterinerid);


--
-- TOC entry 4883 (class 2606 OID 18101)
-- Name: sahip sahip_sahipid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahip
    ADD CONSTRAINT sahip_sahipid_fkey FOREIGN KEY (sahipid) REFERENCES public.kullanici(kullaniciid);


--
-- TOC entry 4900 (class 2606 OID 18801)
-- Name: sahiphayvan sahiphayvan_hayvanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahiphayvan
    ADD CONSTRAINT sahiphayvan_hayvanid_fkey FOREIGN KEY (hayvanid) REFERENCES public.hayvan(hayvanid) ON DELETE CASCADE;


--
-- TOC entry 4901 (class 2606 OID 18253)
-- Name: sahiphayvan sahiphayvan_sahipid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahiphayvan
    ADD CONSTRAINT sahiphayvan_sahipid_fkey FOREIGN KEY (sahipid) REFERENCES public.sahip(sahipid);


--
-- TOC entry 4894 (class 2606 OID 18324)
-- Name: sahiplendirmebelgesi sahiplendirmebelgesi_barinakid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahiplendirmebelgesi
    ADD CONSTRAINT sahiplendirmebelgesi_barinakid_fkey FOREIGN KEY (barinakid) REFERENCES public.barinak(barinakid);


--
-- TOC entry 4908 (class 2606 OID 18315)
-- Name: stok stok_barinakid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stok
    ADD CONSTRAINT stok_barinakid_fkey FOREIGN KEY (barinakid) REFERENCES public.barinak(barinakid);


--
-- TOC entry 4886 (class 2606 OID 18131)
-- Name: veteriner veteriner_veterinerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veteriner
    ADD CONSTRAINT veteriner_veterinerid_fkey FOREIGN KEY (veterinerid) REFERENCES public.kullanici(kullaniciid);


--
-- TOC entry 4882 (class 2606 OID 18091)
-- Name: yonetici yonetici_yoneticiid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yonetici
    ADD CONSTRAINT yonetici_yoneticiid_fkey FOREIGN KEY (yoneticiid) REFERENCES public.kullanici(kullaniciid);


--
-- TOC entry 4906 (class 2606 OID 18303)
-- Name: yoneticibasvuru yoneticibasvuru_basvuruid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yoneticibasvuru
    ADD CONSTRAINT yoneticibasvuru_basvuruid_fkey FOREIGN KEY (basvuruid) REFERENCES public.basvuru(basvuruid);


--
-- TOC entry 4907 (class 2606 OID 18298)
-- Name: yoneticibasvuru yoneticibasvuru_yoneticiid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yoneticibasvuru
    ADD CONSTRAINT yoneticibasvuru_yoneticiid_fkey FOREIGN KEY (yoneticiid) REFERENCES public.yonetici(yoneticiid);


--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2026-04-18 00:52:52

--
-- PostgreSQL database dump complete
--

\unrestrict BsuFNhU4mC4jc8SfMtJnejhHl7NYy7LLZB2sgCdh3bVe70w6rhbfy8ipINfcaSM

