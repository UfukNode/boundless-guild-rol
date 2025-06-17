# Boundless Guild Rol Görev Rehberi:
![image](https://github.com/user-attachments/assets/a5167f89-915b-4767-b012-13f766421209)

Bu rehber'de Script otomatik olarak tüm gereklilikleri kuracak ve işlemleri gerçekleştirecektir. Adımları terminal üzerinden takip edebilirsiniz.
Dikkat: 
Bu bir node kurulumu değildir. Sadece görevi yapmak için, sözleşmeyle etkileşime girip para göndereceğiz.

---

Şartlar:

- 6 aydan eski github hesabı.
- 6 aydan eski discord hesabı.
- Yeni bir metamask cüzdanı.
- Bunlara sahip değilseniz, aşağıdaki son görevi tamamlamanız hiçbir işe yaramayacaktır.
  

## Gereksinimler:

Ücretsiz sunucu sağlayıcılar üzerinde bu işlemi gerçekleştirebilirsiniz. En ucuz sunucu dahil olabilir.

---

## Kurulum Öncesi Gereklilikler:

1. **Guil Hesapları Bağla**
   - [Guild](https://guild.xyz/boundless-xyz) git.
   - Yeni oluşturduğun Metamask cüzdanını bağla.
   - Discord ve github hesabını bağla.

1. **Alchemy Base Mainnet RPC URL**
   - [Alchemy](https://www.alchemy.com/) hesabı oluşturun.
   - Base Mainnet için RPC alın.
   - Format: `https://base-mainnet.g.alchemy.com/v2/YOUR_API_KEY`

2. **Cüzdan Bilgileri**
   - **ÖNEMLİ:** Sadece boş ve kullanmadığınız cüzdan kullanın.
   - Private key'i hazır bulundurun.
  
3. **Gerekli Bakiyeler**
   - **Prover Rol için:** 10+ USDC + 1$ ETH (gas)
   - **Dev Rol için:** 0.000001+ ETH + gas için ETH
   - **Her ikisi için:** 10+ USDC + 0.000001+ ETH + 1-2$ ETH (komisyon) = Toplam 12$
  
---

## Kurulum Adımları:

### 1. Sunucuya Bağlanın:

→ Terminalinizi açın ve aşağıdaki komutu çalıştırarak sunucunuza bağlanın.
```bash
ssh root@sunucu-ip-gir
```

---

### 2. Gerekli Bağımlılıkların Kurun:

```bash
sudo apt update && sudo apt install -y curl
```

---

### 3. Script'i İndirin ve Çalıştırın

**Veya tek komutla:**
```bash
bash <(curl -s https://raw.githubusercontent.com/UfukNode/boundless-guild-rol/refs/heads/main/guild.sh)
```

📌 Aşağıdaki bilgileri girdikten sonra gerekli araçları kurması uzun sürebilir. Lütfen, sabırla olun! 

---

### 4. Scriptin İsteyeceği Bilgiler:

1. **RPC URL Girişi**
- Alchemy Base Mainnet RPC URL'nizi girin: https://base-mainnet.g.alchemy.com/v2/YOUR_API_KEY

2. **Private Key Girişi**
- Cüzdan Private Key'inizi girin (görünmeyecek): [GİZLİ GİRİŞ]

3. **Rol Seçimi**
   1) Prover (10 USDC gerekli)
   2) Dev (0.000001 ETH gerekli)
   3) Her ikisini de yap (10 USDC + 0.000001 ETH gerekli)

4. **Miktar Ayarlama**
   - Varsayılan değerleri kullanabilir veya değiştirebilirsiniz

5. **Bakiye Kontrolü**
   - Script gerekli bakiyeleri gösterir.
   - Onayınızı bekler.

5. **İşlem Gerçekleştirme**
   - Blockchain işlemlerini gerçekleştirir.
  
![image](https://github.com/user-attachments/assets/b71153d6-af64-4247-9fb1-171cf4f61351)

---

### ✅ Başarılı Kurulum Sonrası:

Aşağıdaki gibi bir çıktı alacaksınız. Görevleri onaylamak için https://guild.xyz/boundless-xyz sayfasına dönebilirsiniz.

![image](https://github.com/user-attachments/assets/b3e8a145-fd08-4a82-99a4-fa45d9e80fc2)

---

## ⚠️ Sorun Giderme

**Problem:** Yetersiz bakiye hatası:
- Cüzdan bakiyesini kontrol edin.
- Gas fee'leri için ekstra ETH bulundurun.
- Base network'te işlem yapıldığından emin olun.

**Problem:** RPC bağlantı hatası:
- Alchemy RPC URL'ini kontrol edin.
- API key'in doğru olduğundan emin olun.

