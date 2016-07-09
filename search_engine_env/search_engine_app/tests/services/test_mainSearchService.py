import unittest

import os
from  search_engine_app.services.MainSearchService import MainSearchService
from  search_engine_app.tests.services.test_googleSearch import googleSearchTests

mockupPath = googleSearchTests.getGoogleResponseMockupFilePath()
MainSearchService.setMockupMode(mockupPath)

class mainSearchServiceTests(unittest.TestCase):
    SEARCH_LINES_TEST_FILE = 'search_lines'
    def test_searchOnGoogleFromFile(self):
        try:
            dir = os.path.dirname(__file__)
            path_to_test_settings_file = os.path.join(dir, self.SEARCH_LINES_TEST_FILE)
            file = open(path_to_test_settings_file,'r')
            expectedResponse = ''
            actualResponse = MainSearchService.searchOnGoogleFromFile(file)
        except Exception as e:
            self.assertTrue(False,str(e))
        return actualResponse

if __name__ == "__main__":
    unittest.main()