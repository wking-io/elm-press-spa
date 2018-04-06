/**
 * Stores paths used by webpack
 */
import path from 'path';

const AppConfig = {
  paths: {
    root: path.resolve(__dirname),
    src: path.resolve(__dirname, 'src'),
    build: path.resolve(__dirname, 'build'),
    dist: path.resolve(__dirname, 'dist'),
  },
  entries: {
    main: path.resolve(__dirname, 'src/main.js'),
  },
};

export default AppConfig;
