import { ethers } from "ethers";
const { getDefaultProvider, JsonRpcProvider } = ethers;

async function main() {
    try {
        console.log("🔗 Iniciando conexiones a diferentes redes blockchain...\n");
        
        // ========================================
        // PROVEEDORES POR DEFECTO (DefaultProvider)
        // ========================================
        
        // Conectar usando TU API key de Alchemy (sin límites de claves compartidas)
        console.log("📡 Conectando a Ethereum Mainnet con TU Alchemy API...");
        const providerMainnet = new JsonRpcProvider('https://eth-mainnet.g.alchemy.com/v2/Na9O_bKcUSD9oml_Pske6');
        
        // Conectar a Sepolia usando TU API key también
        console.log("🧪 Conectando a Sepolia Testnet con TU Alchemy API...");
        const providerSepolia = new JsonRpcProvider('https://eth-sepolia.g.alchemy.com/v2/Na9O_bKcUSD9oml_Pske6');
        
        // Para Polygon, usaremos solo Mainnet por ahora (Alchemy no tiene Polygon gratis)
        console.log("🟣 Saltando Polygon por ahora (Alchemy requiere plan pago para Polygon)...");

        // ========================================
        // OBTENER NÚMEROS DE BLOQUE ACTUALES
        // ========================================
        
        console.log("\n📊 Obteniendo números de bloque actuales...\n");
        
        // El número de bloque indica cuántos bloques se han minado
        // Un número más alto = blockchain más activa
        const blockNumberMainnet = await providerMainnet.getBlockNumber();
        const blockNumberSepolia = await providerSepolia.getBlockNumber();

        // Mostrar resultados con formato
        console.log(`🌐 Ethereum Mainnet - Bloque actual: ${blockNumberMainnet.toLocaleString()}`);
        console.log(`🧪 Sepolia Testnet - Bloque actual: ${blockNumberSepolia.toLocaleString()}`);
        console.log(`🟣 Polygon Network - Saltado (no incluido en plan gratuito de Alchemy)`);
        
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

        // Conexión directa a Alchemy con tu API Key
        console.log("⚗️  Probando conexión con Alchemy...");
        try {
            const providerAlchemy = new JsonRpcProvider('https://eth-mainnet.g.alchemy.com/v2/Na9O_bKcUSD9oml_Pske6');
            const blockNumberMainnetAlchemy = await providerAlchemy.getBlockNumber();
            console.log(`⚗️  Alchemy Mainnet - Bloque actual: ${blockNumberMainnetAlchemy.toLocaleString()}`);
            console.log("✅ Alchemy: Conectado exitosamente con tu API Key!");
        } catch (error) {
            console.log("❌ Alchemy: Error de conexión -", error.message);
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