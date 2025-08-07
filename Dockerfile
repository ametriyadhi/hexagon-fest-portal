# --- STAGE 1: Build ---
# Menggunakan image Node.js versi 18-alpine sebagai dasar untuk membangun aplikasi React.
# 'alpine' adalah versi yang sangat ringan. Kita menamainya 'builder'.
FROM node:18-alpine AS builder

# Menetapkan direktori kerja di dalam container
WORKDIR /app

# Menyalin file package.json dan package-lock.json terlebih dahulu
# Ini memanfaatkan cache Docker, sehingga 'npm install' tidak selalu dijalankan jika tidak ada perubahan dependensi.
COPY package*.json ./

# Menginstal semua dependensi proyek
RUN npm install

# Menyalin sisa file proyek ke dalam container
COPY . .

# Menjalankan skrip build untuk membuat folder 'build' yang siap produksi
RUN npm run build

# --- STAGE 2: Production ---
# Menggunakan image Nginx (web server yang sangat ringan dan cepat) sebagai dasar untuk produksi.
FROM nginx:stable-alpine

# Menyalin HANYA folder 'build' yang sudah jadi dari stage 'builder'
# ke dalam direktori web root default Nginx.
# Ini membuat image produksi kita sangat kecil dan aman.
COPY --from=builder /app/build /usr/share/nginx/html

# Memberi tahu Docker bahwa container akan berjalan di port 80
EXPOSE 80

# Perintah default untuk menjalankan Nginx saat container dimulai
CMD ["nginx", "-g", "daemon off;"]