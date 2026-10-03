import '../../features/movies/data/tmdb_api.dart';
import '../../features/youtube/data/youtube_api.dart';
import 'api_client.dart';

/// One shared HTTPS client for the movie and video features.
final ApiClient apiClient = ApiClient();
final TmdbApi tmdbApi = TmdbApi(apiClient);
final YoutubeApi youtubeApi = YoutubeApi(apiClient);
