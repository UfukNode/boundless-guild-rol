#!/bin/bash

# Boundless Guild Görevi Scripti
# Renkli çıktılar için
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logo ve hoşgeldin mesajı
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                  BOUNDLESS GUILD GÖREVI                  ║"
echo "║                     DEV ve PROVE ROL                     ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Hata durumunda scripti durdur
set -e

# Kullanıcı bilgilerini al
get_user_inputs() {
    echo -e "${YELLOW}Kurulum için gerekli bilgileri girin:${NC}"
    echo ""
    
    read -p "Alchemy Base Mainnet RPC URL'nizi girin: " ALCHEMY_RPC
    if [[ -z "$ALCHEMY_RPC" ]]; then
        echo -e "${RED}❌ RPC URL boş olamaz!${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${YELLOW}Private key girişi güvenlik açısından kritiktir. Sıfır bir cüzdan ile bu işlemi tamamlayın!${NC}"
    read -s -p "Cüzdan Private Key'inizi girin (görünmeyecek): " PRIVATE_KEY
    echo ""
    if [[ -z "$PRIVATE_KEY" ]]; then
        echo -e "${RED}❌ Private key boş olamaz!${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${BLUE}Hangi rolü seçmek istiyorsunuz?${NC}"
    echo "1) Prover (10 USDC gerekli)"
    echo "2) Dev (0.000001 ETH gerekli)"
    echo "3) Her ikisini de yap (10 USDC + 0.000001 ETH gerekli)"
    read -p "Seçiminizi yapın (1, 2 veya 3): " ROLE_CHOICE
    
    if [[ "$ROLE_CHOICE" == "1" ]]; then
        ROLE="prover"
        read -p "Stake edilecek USDC miktarını girin (varsayılan: 10): " STAKE_AMOUNT
        STAKE_AMOUNT=${STAKE_AMOUNT:-10}
    elif [[ "$ROLE_CHOICE" == "2" ]]; then
        ROLE="dev"
        read -p "Deposit edilecek ETH miktarını girin (varsayılan: 0.000001): " DEPOSIT_AMOUNT
        DEPOSIT_AMOUNT=${DEPOSIT_AMOUNT:-0.000001}
    elif [[ "$ROLE_CHOICE" == "3" ]]; then
        ROLE="both"
        read -p "Stake edilecek USDC miktarını girin (varsayılan: 10): " STAKE_AMOUNT
        STAKE_AMOUNT=${STAKE_AMOUNT:-10}
        read -p "Deposit edilecek ETH miktarını girin (varsayılan: 0.000001): " DEPOSIT_AMOUNT
        DEPOSIT_AMOUNT=${DEPOSIT_AMOUNT:-0.000001}
    else
        echo -e "${RED}❌ Geçersiz seçim!${NC}"
        exit 1
    fi
}

# Sistem güncellemesi
update_system() {
    echo -e "${BLUE}Sistem güncelleniyor...${NC}"
    sudo apt update -y
    sudo apt install -y curl git build-essential cmake protobuf-compiler
    echo -e "${GREEN}Sistem güncellendi${NC}"
}

# Screen session oluştur
create_screen() {
    echo -e "${BLUE}Screen session oluşturuluyor...${NC}"
    if screen -list | grep -q "boundless"; then
        echo -e "${YELLOW}Boundless screen session zaten mevcut${NC}"
    else
        screen -dmS boundless
        echo -e "${GREEN}Screen session oluşturuldu${NC}"
    fi
}

# Repository klonla
clone_repo() {
    echo -e "${BLUE}Boundless repository klonlanıyor...${NC}"
    if [ -d "boundless" ]; then
        echo -e "${YELLOW}Boundless klasörü zaten mevcut, güncelleniyor...${NC}"
        cd boundless
        git pull
        cd ..
    else
        git clone https://github.com/boundless-xyz/boundless
    fi
    cd boundless
    echo -e "${GREEN}Repository hazır${NC}"
}

# Rust kurulumu
install_rust() {
    echo -e "${BLUE}Rust kuruluyor...${NC}"
    if command -v rustc &> /dev/null; then
        echo -e "${YELLOW}Rust zaten kurulu${NC}"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
        echo -e "${GREEN}Rust kuruldu${NC}"
    fi
}

# RISC Zero kurulumu
install_risc_zero() {
    echo -e "${BLUE}RISC Zero kuruluyor...${NC}"
    curl -L https://risczero.com/install | bash
    source ~/.bashrc
    export PATH="$HOME/.risc0/bin:$PATH"
    rzup install
    echo -e "${GREEN}RISC Zero kuruldu${NC}"
}

# Bento Client kurulumu
install_bento() {
    echo -e "${BLUE}Bento Client kuruluyor...${NC}"
    source $HOME/.cargo/env
    cargo install --git https://github.com/risc0/risc0 bento-client --bin bento_cli
    echo -e "${GREEN}Bento Client kuruldu${NC}"
}

# PATH güncelleme
update_path() {
    echo -e "${BLUE}PATH güncelleniyor...${NC}"
    export PATH="$HOME/.cargo/bin:$PATH"
    if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.bashrc; then
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    fi
    source ~/.bashrc
    echo -e "${GREEN}PATH güncellendi${NC}"
}

# CLI kurulumu
install_cli() {
    echo -e "${BLUE}Boundless CLI kuruluyor...${NC}"
    source $HOME/.cargo/env
    cargo install --locked boundless-cli
    echo -e "${GREEN}Boundless CLI kuruldu${NC}"
}

# Env dosyası oluştur
create_env() {
    echo -e "${BLUE}Environment dosyası oluşturuluyor...${NC}"
    cat > .env.base << EOF
# Base contract addresses
export VERIFIER_ADDRESS=0x0b144e07a0826182b6b59788c34b32bfa86fb711
export BOUNDLESS_MARKET_ADDRESS=0x26759dbB201aFbA361Bec78E097Aa3942B0b4AB8
export SET_VERIFIER_ADDRESS=0x8C5a8b5cC272Fe2b74D18843CF9C3aCBc952a760

# Public order stream URL
export ORDER_STREAM_URL="https://base-mainnet.beboundless.xyz"
export ETH_RPC_URL="$ALCHEMY_RPC"
export PRIVATE_KEY="$PRIVATE_KEY"
EOF
    source .env.base
    echo -e "${GREEN}Environment dosyası oluşturuldu${NC}"
}

# Cüzdan bakiyesi kontrol et
check_balance() {
    echo -e "${BLUE}💰 Cüzdan bakiyesi kontrol ediliyor...${NC}"
    echo -e "${YELLOW}⚠️  Lütfen cüzdanınızda yeterli bakiye olduğundan emin olun:${NC}"
    
    if [[ "$ROLE" == "prover" ]]; then
        echo -e "${YELLOW}   - ${STAKE_AMOUNT} USDC${NC}"
        echo -e "${YELLOW}   - Az miktarda ETH (gas için, ~2-3$)${NC}"
    elif [[ "$ROLE" == "dev" ]]; then
        echo -e "${YELLOW}   - ${DEPOSIT_AMOUNT} ETH${NC}"
        echo -e "${YELLOW}   - Az miktarda ETH (gas için)${NC}"
    else
        echo -e "${YELLOW}   - ${STAKE_AMOUNT} USDC${NC}"
        echo -e "${YELLOW}   - ${DEPOSIT_AMOUNT} ETH${NC}"
        echo -e "${YELLOW}   - Az miktarda ETH (gas için, ~5-6$)${NC}"
    fi
    
    echo ""
    read -p "Bakiyeniz yeterli mi? (y/n): " BALANCE_OK
    if [[ "$BALANCE_OK" != "y" && "$BALANCE_OK" != "Y" ]]; then
        echo -e "${RED}❌ Lütfen önce cüzdanınıza yeterli bakiye yükleyin${NC}"
        exit 1
    fi
}

# Stake/Deposit işlemi
execute_transaction() {
    echo -e "${BLUE} İşlem gerçekleştiriliyor...${NC}"
    
    if [[ "$ROLE" == "prover" ]]; then
        echo -e "${YELLOW}${STAKE_AMOUNT} USDC stake ediliyor...${NC}"
        boundless \
          --rpc-url "$ETH_RPC_URL" \
          --private-key "$PRIVATE_KEY" \
          --boundless-market-address 0x26759dbB201aFbA361Bec78E097Aa3942B0b4AB8 \
          --set-verifier-address 0x8C5a8b5cC272Fe2b74D18843CF9C3aCBc952a760 \
          --verifier-router-address 0x0b144e07a0826182b6b59788c34b32bfa86fb711 \
          --order-stream-url "https://base-mainnet.beboundless.xyz" \
          account deposit-stake $STAKE_AMOUNT
          
    elif [[ "$ROLE" == "dev" ]]; then
        echo -e "${YELLOW}${DEPOSIT_AMOUNT} ETH deposit ediliyor...${NC}"
        boundless \
          --rpc-url "$ETH_RPC_URL" \
          --private-key "$PRIVATE_KEY" \
          --boundless-market-address 0x26759dbB201aFbA361Bec78E097Aa3942B0b4AB8 \
          --set-verifier-address 0x8C5a8b5cC272Fe2b74D18843CF9C3aCBc952a760 \
          --verifier-router-address 0x0b144e07a0826182b6b59788c34b32bfa86fb711 \
          --order-stream-url "https://base-mainnet.beboundless.xyz/" \
          account deposit $DEPOSIT_AMOUNT
          
    else # both
        echo -e "${YELLOW}${STAKE_AMOUNT} USDC stake ediliyor...${NC}"
        boundless \
          --rpc-url "$ETH_RPC_URL" \
          --private-key "$PRIVATE_KEY" \
          --boundless-market-address 0x26759dbB201aFbA361Bec78E097Aa3942B0b4AB8 \
          --set-verifier-address 0x8C5a8b5cC272Fe2b74D18843CF9C3aCBc952a760 \
          --verifier-router-address 0x0b144e07a0826182b6b59788c34b32bfa86fb711 \
          --order-stream-url "https://base-mainnet.beboundless.xyz" \
          account deposit-stake $STAKE_AMOUNT
          
        echo -e "${YELLOW}${DEPOSIT_AMOUNT} ETH deposit ediliyor...${NC}"
        sleep 2  # İşlemler arası kısa bekleme
        boundless \
          --rpc-url "$ETH_RPC_URL" \
          --private-key "$PRIVATE_KEY" \
          --boundless-market-address 0x26759dbB201aFbA361Bec78E097Aa3942B0b4AB8 \
          --set-verifier-address 0x8C5a8b5cC272Fe2b74D18843CF9C3aCBc952a760 \
          --verifier-router-address 0x0b144e07a0826182b6b59788c34b32bfa86fb711 \
          --order-stream-url "https://base-mainnet.beboundless.xyz/" \
          account deposit $DEPOSIT_AMOUNT
    fi
    
    echo -e "${GREEN}✅ İşlem(ler) tamamlandı${NC}"
}

# Sonuç mesajları
show_completion() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                GUILD GÖREVİ TAMAMLANDI!                 ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BLUE}Tamamlanan işlemler:${NC}"
    if [[ "$ROLE" == "prover" ]]; then
        echo -e "${GREEN}   ✅ Prover olarak ${STAKE_AMOUNT} USDC stake edildi${NC}"
    elif [[ "$ROLE" == "dev" ]]; then
        echo -e "${GREEN}   ✅ Dev olarak ${DEPOSIT_AMOUNT} ETH deposit edildi${NC}"
    else
        echo -e "${GREEN}   ✅ Prover olarak ${STAKE_AMOUNT} USDC stake edildi${NC}"
        echo -e "${GREEN}   ✅ Dev olarak ${DEPOSIT_AMOUNT} ETH deposit edildi${NC}"
    fi
    echo ""
    
    echo -e "${BLUE}Sırada yapılacaklar:${NC}"
    echo ""
    echo -e "${YELLOW}1. Guild görevlerini tamamlayın:${NC}"
    echo "   https://guild.xyz/boundless-xyz"
    echo ""
    echo -e "${YELLOW}2. Discord sunucusuna katılın ve rollerinizi alın${NC}"
    echo ""
    echo -e "${YELLOW}3. Boundless Discord görevlerini tamamlayın${NC}"
    echo ""
    echo -e "${GREEN}🎉 Başarılar! Boundless ağına hoş geldiniz!${NC}"
}

# Ana fonksiyon
main() {
    echo -e "${BLUE}🚀 Kurulum başlıyor...${NC}"
    echo ""
    
    get_user_inputs
    echo ""
    echo -e "${BLUE}Kurulum özeti:${NC}"
    echo -e "${YELLOW}   RPC URL: ${ALCHEMY_RPC}${NC}"
    
    if [[ "$ROLE" == "prover" ]]; then
        echo -e "${YELLOW}   Rol: Prover${NC}"
        echo -e "${YELLOW}   Stake: ${STAKE_AMOUNT} USDC${NC}"
    elif [[ "$ROLE" == "dev" ]]; then
        echo -e "${YELLOW}   Rol: Dev${NC}"
        echo -e "${YELLOW}   Deposit: ${DEPOSIT_AMOUNT} ETH${NC}"
    else
        echo -e "${YELLOW}   Rol: Her ikisi (Prover + Dev)${NC}"
        echo -e "${YELLOW}   Stake: ${STAKE_AMOUNT} USDC${NC}"
        echo -e "${YELLOW}   Deposit: ${DEPOSIT_AMOUNT} ETH${NC}"
    fi
    
    echo ""
    read -p "Devam etmek istiyor musunuz? (y/n): " CONTINUE
    if [[ "$CONTINUE" != "y" && "$CONTINUE" != "Y" ]]; then
        echo -e "${YELLOW}❌ Kurulum iptal edildi${NC}"
        exit 0
    fi
    
    echo ""
    update_system
    create_screen
    clone_repo
    install_rust
    install_risc_zero
    install_bento
    update_path
    install_cli
    create_env
    check_balance
    execute_transaction
    show_completion
}

# Error handling
trap 'echo -e "${RED}❌ Bir hata oluştu! Script durduruluyor...${NC}"; exit 1' ERR

# Scripti çalıştır
main
