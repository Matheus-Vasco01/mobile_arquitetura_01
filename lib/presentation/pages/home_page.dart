import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/session/session_manager.dart';
import 'bloc_api_products_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionManager>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Velour",
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF6B1123),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (session.isLoggedIn) ...[
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(session.currentUser!.image),
                radius: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF6B1123)),
              tooltip: "Sair",
              onPressed: () {
                context.read<SessionManager>().logout();
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            if (session.isLoggedIn)
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF6B1123),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(session.currentUser!.image),
                ),
                accountName: Text(
                  "${session.currentUser!.firstName} ${session.currentUser!.lastName}",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                accountEmail: Text(
                  session.currentUser!.email,
                  style: GoogleFonts.montserrat(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              )
            else
              DrawerHeader(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Velour",
                      style: GoogleFonts.playfairDisplay(
                        color: const Color(0xFF6B1123),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF6B1123)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            _buildDrawerItem(
                context, Icons.laptop, "Eletrônicos", "electronics"),
            _buildDrawerItem(
                context, Icons.diamond_outlined, "Joias", "jewelery"),
            _buildDrawerItem(
                context, Icons.checkroom, "Moda Masculina", "men's clothing"),
            _buildDrawerItem(context, Icons.person_outline, "Moda Feminina",
                "women's clothing"),
            const Spacer(),
            if (session.isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF6B1123)),
                title: Text(
                  "Sair",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<SessionManager>().logout();
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Buscar produtos...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    "Olá, ${session.currentUser?.firstName ?? 'Visitante'}!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Seja bem-vindo de volta à Velour Store",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BlocApiProductPage(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Explorar Catálogo"),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              color: const Color(0xFFF9F9F9),
              child: Column(
                children: [
                  Text(
                    "Nossas Categorias",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Explore nossa seleção cuidadosamente curada de produtos premium.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildCategoryCard(context, Icons.laptop, "Eletrônicos",
                          "24 produtos", "electronics"),
                      _buildCategoryCard(context, Icons.diamond_outlined,
                          "Joias", "18 produtos", "jewelery"),
                      _buildCategoryCard(context, Icons.checkroom,
                          "Moda Masculina", "32 produtos", "men's clothing"),
                      _buildCategoryCard(context, Icons.person_outline,
                          "Moda Feminina", "45 produtos", "women's clothing"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, String category) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6B1123)),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF333333),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocApiProductPage(initialCategory: category),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, IconData icon, String title,
      String count, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocApiProductPage(initialCategory: category),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B1123).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF6B1123), size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  count,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Icon(Icons.arrow_forward,
                    size: 14, color: Color(0xFF333333)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
