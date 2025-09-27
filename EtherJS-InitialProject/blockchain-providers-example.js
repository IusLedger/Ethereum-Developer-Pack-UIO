import { ethers } from "ethers";
const { getDefaultProvider, JsonRpcProvider } = ethers;

async function main() {
    try {
        console.log("🔗 Iniciando conexiones a diferentes redes blockchain...\n");
        
        // ========================================
        // PROVEEDORES POR DEFECTO (DefaultProvider)
        // ========================================
        
        // Conectar a Ethereum Mainnet (red principal)
        console.log("📡 Conectando a Ethereum Mainnet...");
        const providerMainnet = ethers.getDefaultProvider("mainnet");
        
        // Conectar a Sepolia (red de pruebas)
        console.log("🧪 Conectando a Sepolia Testnet...");
        const providerSepolia = ethers.getDefaultProvider("sepolia");
        
        // Conectar a Polygon/Matic (sidechain más rápida y barata)
        console.log("🟣 Conectando a Polygon (Matic)...");
        const providerMatic = ethers.getDefaultProvider("matic", {
            exclusive: ["etherscan", "infura"] // Solo usar estos servicios
        });

        // ========================================
        // OBTENER NÚMEROS DE BLOQUE ACTUALES
        // ========================================
        
        console.log("\n📊 Obteniendo números de bloque actuales...\n");
        
        // El número de bloque indica cuántos bloques se han minado
        // Un número más alto = blockchain más activa
        const blockNumberMainnet = await providerMainnet.getBlockNumber();
        const blockNumberSepolia = await providerSepolia.getBlockNumber();
        const blockNumberMatic = await providerMatic.getBlockNumber();

        // Mostrar resultados con formato
        console.log(`🌐 Ethereum Mainnet - Bloque actual: ${blockNumberMainnet.toLocaleString()}`);
        console.log(`🧪 Sepolia Testnet - Bloque actual: ${blockNumberSepolia.toLocaleString()}`);
        console.log(`🟣 Polygon Network - Bloque actual: ${blockNumberMatic.toLocaleString()}`);
        
        // ========================================
        // PROVEEDORES ESPECÍFICOS (JsonRpcProvider)
        // ========================================
        
        console.log("\n🔧 Probando conexiones específicas...\n");
        
        // Red local (para desarrollo)
        // Descomenta la siguiente línea si tienes un nodo local corriendo
        // const providerLocal = new JsonRpcProvider('http://localhost:8545');
        console.log("💻 Red local: Comentada (descomenta si tienes Ganache/Hardhat ejecutándose)");
        
        // Conexión directa a Infura
        // NOTA: Necesitas reemplazar 'your-infura-project-id' con tu ID real
        console.log("🌍 Probando conexión con Infura...");
        try {
            const providerInfura = new JsonRpcProvider('https://mainnet.infura.io/v3/your-infura-project-id');
            // Esta línea fallará sin un Project ID válido
            // const blockNumberMainnetInfura = await providerInfura.getBlockNumber();
            // console.log(`🌍 Infura Mainnet - Bloque actual: ${blockNumberMainnetInfura.toLocaleString()}`);
            console.log("⚠️  Infura: Necesitas un Project ID válido para conectar");
        } catch (error) {
            console.log("❌ Infura: Error de conexión (Project ID requerido)");
        }

        // Conexión directa a Alchemy  
        // NOTA: Necesitas reemplazar 'your-alchemy-API-Key' con tu clave real
        console.log("⚗️  Probando conexión con Alchemy...");
        try {
            const providerAlchemy = new JsonRpcProvider('https://eth-mainnet.alchemyapi.io/v2/your-alchemy-API-Key');
            // Esta línea fallará sin una API Key válida
            // const blockNumberMainnetAlchemy = await providerAlchemy.getBlockNumber();
            // console.log(`⚗️  Alchemy Mainnet - Bloque actual: ${blockNumberMainnetAlchemy.toLocaleString()}`);
            console.log("⚠️  Alchemy: Necesitas una API Key válida para conectar");
        } catch (error) {
            console.log("❌ Alchemy: Error de conexión (API Key requerida)");
        }

        // ========================================
        // INFORMACIÓN ADICIONAL
        // ========================================
        
        console.log("\n📚 Información adicional:");
        console.log("• getDefaultProvider usa múltiples servicios automáticamente");
        console.log("• JsonRpcProvider se conecta a un endpoint específico");
        console.log("• Los números de bloque cambian constantemente (cada ~12-15 seg en Ethereum)");
        console.log("• Las testnets son gratis pero los tokens no tienen valor real");
        
        console.log("\n✅ Demostración completada exitosamente!");

    } catch (error) {
        console.error("❌ Error durante la ejecución:", error.message);
        console.log("\n🔧 Posibles soluciones:");
        console.log("• Verifica tu conexión a internet");
        console.log("• Asegúrate de tener ethers.js instalado: npm install ethers");
        console.log("• Para servicios específicos, necesitas claves API válidas");
    }
}

// ========================================
// EJECUTAR EL PROGRAMA
// ========================================

console.log("🚀 Iniciando demostración de proveedores blockchain...\n");
main();