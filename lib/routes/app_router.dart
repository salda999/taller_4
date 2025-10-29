import 'package:go_router/go_router.dart';
import 'package:parqueadero_2025_g2/views/ciclo_vida/ciclo_vida_screen.dart';
import 'package:parqueadero_2025_g2/views/paso_parametros/detalle_screen.dart';
import 'package:parqueadero_2025_g2/views/paso_parametros/paso_parametros_screen.dart';

import '../views/future/future_view.dart';
import '../views/home/home_screen.dart';
import '../views/isolate/isolate_view.dart';
import '../views/pokemons/pokemon_detail_view.dart';
import '../views/pokemons/pokemon_list_view.dart';
import '../views/comidas/comidas_detail_view.dart';
import '../views/comidas/comidas_list_view.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/profile_screen.dart';
import '../services/auth_service_hybrid.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    
    // Si está en login o register y ya está logueado, redirige al perfil
    if ((state.matchedLocation == '/login' || state.matchedLocation == '/register') && isLoggedIn) {
      return '/profile';
    }
    
    // Si está en una ruta protegida y no está logueado, redirige a login
    if (!isLoggedIn && state.matchedLocation != '/login' && state.matchedLocation != '/register') {
      return '/login';
    }
    
    return null; // No redirigir
  },
  routes: [
    // Rutas de autenticación
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(), // Usa HomeView
    ),
    // Rutas para el paso de parámetros
    GoRoute(
      path: '/paso_parametros',
      name: 'paso_parametros',
      builder: (context, state) => const PasoParametrosScreen(),
    ),

    // !Ruta para el detalle con parámetros
    GoRoute(
      path:
          '/detalle/:parametro/:metodo', //la ruta recibe dos parametros los " : " indican que son parametros
      builder: (context, state) {
        //*se capturan los parametros recibidos
        // declarando las variables parametro y metodo
        // es final porque no se van a modificar
        final parametro = state.pathParameters['parametro']!;
        final metodo = state.pathParameters['metodo']!;
        return DetalleScreen(parametro: parametro, metodoNavegacion: metodo);
      },
    ),
    //!Ruta para el ciclo de vida
    GoRoute(
      path: '/ciclo_vida',
      builder: (context, state) => const CicloVidaScreen(),
    ),
    //!Ruta para FUTURE
    GoRoute(
      path: '/future',
      name: 'future',
      builder: (context, state) => const FutureView(),
    ),
    //!Ruta para ISOLATE
    GoRoute(
      path: '/isolate',
      name: 'isolate',
      builder: (context, state) => const IsolateView(),
    ),
    //!Ruta para POKEMON
    GoRoute(
      path: '/pokemon',
      name: 'pokemon',
      builder: (context, state) => const PokemonListView(),
    ),
    //!Ruta para detalle de pokemones
    GoRoute(
      path: '/pokemon/:name', // se recibe el nombre del pokemon como parametro
      name: 'pokemon_detail',
      builder: (context, state) {
        final name =
            state.pathParameters['name']!; // se captura el nombre del pokemon.
        return PokemonDetailView(name: name);
      },
    ),
    //!Ruta para COMIDAS
    GoRoute(
      path: '/comidas',
      name: 'comidas',
      builder: (context, state) => const ComidasListView(),
    ),
    //!Ruta para detalle de comidas
    GoRoute(
      path: '/comidas/:id', // se recibe el id de la comida como parametro
      name: 'comidas_detail',
      builder: (context, state) {
        final id =
            state.pathParameters['id']!; // se captura el id de la comida.
        return ComidasDetailView(id: id);
      },
    ),
  ],
);
